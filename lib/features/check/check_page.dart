import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/index.dart';
import '../../domain/index.dart';
import '../../domain/repositories/check/check_repository.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../provider/index.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../product/widget/product_card.dart';
import 'provider/check_product_provider.dart';
import 'provider/check_session_provider.dart';
import 'widget/create_session_bottom_sheet.dart';
import 'widget/inventory_adjust_bottom_sheet.dart';

@RoutePage()
class CheckPage extends ConsumerStatefulWidget {
  const CheckPage({super.key, required this.session});
  final CheckSession session;

  @override
  ConsumerState<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends ConsumerState<CheckPage> {
  CheckSession get session => widget.session;

  bool get isDone => session.status.index >= CheckSessionStatus.completed.index;

  bool _hasPermission(PermissionKey key) {
    return ref.read(currentUserPermissionsProvider).maybeWhen(
          data: (value) => value.contains(key),
          orElse: () => false,
        );
  }

  bool get _canModifySession => !isDone && _hasPermission(PermissionKey.inventoryCreateSession);

  void _openProductDetailBTS(
    Product product, {
    CheckedProduct? currentCheck,
  }) async {
    if (!_canModifySession) {
      return;
    }
    InventoryAdjustBottomSheet(
      product: product,
      currentQuantity: currentCheck?.actualQuantity,
      note: currentCheck?.note,
      onSave: (int quantity, [String? note]) async {
        try {
          // Thêm sản phẩm vào session thông qua repository
          final checkRepo = ref.read(checkedListProvider(session).notifier);
          if (currentCheck != null) {
            //update existing check
            await checkRepo.updateCheck(
              checkedProduct: currentCheck,
              checkQuantity: quantity,
              note: note,
            );
          } else {
            //create new check
            await checkRepo.addCheck(
              product: product,
              checkQuantity: quantity,
              note: note,
            );
          }

          Navigator.pop(context); // Đóng bottom sheet sau khi lưu
        } catch (e) {}
      },
    ).show(context);
  }

  void _onSearchProductResult(Product? product) {
    if (!_canModifySession) {
      return;
    }

    if (product != null) {
      //search for current list of checked products
      final existingCheck = ref.read(checkedListProvider(session).notifier).checkExistProduct(product: product);

      if (existingCheck != null) {
        // Nếu sản phẩm đã được kiểm kê, mở chi tiết kiểm kê hiện tại
        _openProductDetailBTS(product, currentCheck: existingCheck);
      } else {
        _openProductDetailBTS(product);
      }
    }
  }

  Future<void> _onBarcodeScanned(Barcode barcode) async {
    if (!_canModifySession) {
      return;
    }

    try {
      final searchProductRepo = ref.read(searchProductRepositoryProvider);
      final product = await searchProductRepo.searchByBarcode(barcode.rawValue ?? '');
      _onSearchProductResult(product);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi quét mã vạch: $e')),
      );
      return;
    }
  }

  void _onSearchProduct() async {
    if (!_canModifySession) {
      return;
    }

    final product = await SearchItemWidget<Product>(
      itemBuilder: (context, product, index) {
        return ProductCard(
          product: product,
          onTap: () => Navigator.pop(context, product),
        );
      },
      searchItems: (keyword, page, size) async {
        final searchProductRepo = ref.read(searchProductRepositoryProvider);
        final products = await searchProductRepo.search(keyword, page, size);
        return products.data;
      },
    ).show(context);

    _onSearchProductResult(product);
  }

  void _showSessionInfo() {
    final appTheme = context.appTheme;
    SessionDetailBottomSheet(session: widget.session).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);

    return permissionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber, size: 40, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  'Không thể tải quyền truy cập',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentUserPermissionsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (permissions) {
        final theme = context.appTheme;
        final canViewSession = permissions.contains(PermissionKey.inventoryView);
        final canModifySession = permissions.contains(PermissionKey.inventoryCreateSession) && !isDone;
        final canFinalizeSession = permissions.contains(PermissionKey.inventoryFinalizeSession) && !isDone;

        if (!canViewSession) {
          return Scaffold(
            appBar: CustomAppBar(title: widget.session.name),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bạn không có quyền xem chi tiết phiên kiểm kê này.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorBackground,
          appBar: CustomAppBar(
            title: widget.session.name,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  onPressed: _showSessionInfo,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              if (canModifySession)
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorBackgroundSurface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: theme.colorBorderSublest,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorPrimary.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ScannerView(
                          onBarcodeScanned: _onBarcodeScanned,
                          singleScan: true,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorBackgroundSurface,
                  border: Border.all(
                    color: theme.colorBorderSublest,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sản phẩm đã kiểm kê',
                          style: theme.headingSemibold20Default,
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder(
                          future: ref.read(checkRepositoryProvider).getChecksBySession(widget.session.id),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.length ?? 0;
                            return Text(
                              '$count sản phẩm',
                              style: theme.textRegular14Sublest,
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorPrimary.withOpacity(0.1),
                            theme.colorPrimary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorPrimary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: theme.colorPrimary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final checks = ref.watch(checkedListProvider(session)).value;

                    if (checks.isNullOrEmpty) {
                      return SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: theme.colorBackgroundSurface,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: theme.colorPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 40,
                                  color: theme.colorPrimary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Chưa có sản phẩm nào được kiểm kê',
                                style: theme.headingSemibold20Default,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                canModifySession
                                    ? 'Hãy quét mã vạch hoặc tìm kiếm sản phẩm để bắt đầu'
                                    : 'Bạn không có quyền chỉnh sửa phiên kiểm kê này.',
                                style: theme.textRegular14Sublest,
                                textAlign: TextAlign.center,
                              ),
                              if (canModifySession) ...[
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorPrimary,
                                        theme.colorPrimary.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorPrimary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _onSearchProduct,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.search, color: Colors.white),
                                    label: Text(
                                      'Tìm sản phẩm',
                                      style: theme.buttonSemibold14.copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: checks!.length,
                      itemBuilder: (context, index) {
                        final check = checks[index];
                        return CheckProductCard(
                          check: check,
                          onTap: canModifySession
                              ? () => _openProductDetailBTS(check.product, currentCheck: check)
                              : null,
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: canFinalizeSession
              ? Consumer(
                  builder: (context, ref, child) {
                    final haveCheck = ref.watch(checkedListProvider(session)).value.isNotNullAndEmpty;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorBackgroundSurface,
                      ),
                      child: AppButton.primary(
                        title: 'Hoàn thành kiểm kê',
                        onPressed: haveCheck
                            ? () {
                                try {
                                  final notifier = ref.read(loadCheckSessionProvider(ActiveViewType.active).notifier);
                                  notifier.updateStatus(widget.session, CheckSessionStatus.completed);
                                  appRouter.popForced();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lỗi: $e')),
                                  );
                                }
                              }
                            : null,
                      ),
                    );
                  },
                )
              : null,
          floatingActionButton: canModifySession
              ? FloatingActionButton(
                  onPressed: _onSearchProduct,
                  child: const Icon(Icons.search, color: Colors.white, size: 28),
                )
              : null,
        );
      },
    );
  }
}

class CheckProductCard extends StatelessWidget {
  const CheckProductCard({super.key, required this.check, this.onTap});

  final CheckedProduct check;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final product = check.product;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorBackgroundSurface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Product Info Section
                CustomProductCard(
                  product: product,
                  onTap: null, // Disable nested tap
                  bottomWidget: null, // Remove default bottom widget
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  color: theme.colorDivider,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Check Details Section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quantity Info
                          Row(
                            children: [
                              _buildQuantityChip(
                                theme,
                                'Hệ thống',
                                '${check.expectedQuantity}',
                                theme.colorTextSupportBlue,
                              ),
                              const SizedBox(width: 8),
                              _buildQuantityChip(
                                theme,
                                'Thực tế',
                                '${check.actualQuantity}',
                                theme.colorTextSupportGreen,
                              ),
                            ],
                          ),

                          // Note if exists
                          if (check.note != null && check.note!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorPrimary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorPrimary.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.note_alt_outlined,
                                    size: 16,
                                    color: theme.colorPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      check.note!,
                                      style: theme.textRegular12Default.copyWith(
                                        color: theme.colorPrimary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(check.status, theme).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(check.status, theme).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(check.status),
                            color: _getStatusColor(check.status, theme),
                            size: 20,
                          ),
                          const Gap(4),
                          Text(
                            check.differenceText,
                            style: theme.textMedium13Default.copyWith(
                              color: _getStatusColor(check.status, theme),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityChip(dynamic theme, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CheckStatus status, dynamic theme) {
    switch (status) {
      case CheckStatus.match:
        return Colors.green;
      case CheckStatus.surplus:
        return Colors.blue;
      case CheckStatus.shortage:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(CheckStatus status) {
    switch (status) {
      case CheckStatus.match:
        return Icons.check_circle_outline;
      case CheckStatus.surplus:
        return Icons.trending_up;
      case CheckStatus.shortage:
        return Icons.trending_down;
    }
  }
}

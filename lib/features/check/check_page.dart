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

  void _openProductDetailBTS(
    Product product, {
    CheckedProduct? currentCheck,
  }) async {
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

  void _onBarcodeScanned(Barcode barcode) async {
    try {
      final searchProductRepo = ref.read(searchProductRepositoryProvider);
      final product = await searchProductRepo.searchByBarcode(barcode.rawValue ?? '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi quét mã vạch: $e')),
      );
      return;
    }
  }

  void _onSearchProduct() async {
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

    if (product != null) {
      _openProductDetailBTS(product);
    }
  }

  void _showSessionInfo() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin phiên kiểm kê',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Tên phiên: ${widget.session.name}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Người tạo: ${widget.session.createdBy}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Ngày tạo: ${widget.session.startDate.toString().substring(0, 16)}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Trạng thái: ${widget.session.status.toString().split('.').last}',
              style: TextStyle(
                fontSize: 16,
                color: widget.session.status == CheckSessionStatus.inProgress ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.session.note != null && widget.session.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Ghi chú: ${widget.session.note}', style: const TextStyle(fontSize: 16)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.session.name,
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: _showSessionInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Scan View
          if (!isDone)
            SizedBox(
              height: 250,
              child: ScannerView(
                onBarcodeScanned: _onBarcodeScanned,
                singleScan: true,
              ),
            ),

          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách sản phẩm đã kiểm kê',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                FutureBuilder(
                  future: ref.read(checkRepositoryProvider).getChecksBySession(widget.session.id),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return Text(
                      '$count sản phẩm',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
              ],
            ),
          ),

          // Danh sách đã kiểm kê
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final checks = ref.watch(checkedListProvider(session)).value;

                if (checks.isNullOrEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có sản phẩm nào được kiểm kê',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _onSearchProduct,
                          icon: const Icon(Icons.search),
                          label: const Text('Tìm sản phẩm'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: checks!.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final check = checks[index];
                    return CheckProductCard(
                      check: check,
                      onTap: isDone ? null : () => _openProductDetailBTS(check.product, currentCheck: check),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDone
          ? null
          : Consumer(builder: (context, ref, child) {
              final haveCheck = ref.watch(checkedListProvider(session)).value.isNotNullAndEmpty;
              return BottomAppBar(
                padding: EdgeInsets.zero,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: !haveCheck
                              ? null
                              : () {
                                  try {
                                    final notifier = ref.read(loadCheckSessionProvider(ActiveViewType.active).notifier);
                                    notifier.updateStatus(widget.session, CheckSessionStatus.completed);
                                    appRouter.popForced();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $e')),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Hoàn thành'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      floatingActionButton: isDone
          ? null
          : FloatingActionButton(
              onPressed: _onSearchProduct,
              child: const Icon(Icons.search, color: Colors.white),
            ),
    );
  }
}

class CheckProductCard extends StatelessWidget {
  const CheckProductCard({super.key, required this.check, this.onTap});

  final CheckedProduct check;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final product = check.product;
    final theme = context.appTheme;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: CustomProductCard(
        product: product,
        onTap: onTap,
        bottomWidget: Column(
          children: [
            AppDivider(),
            Gap(4),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hệ thống: ${check.expectedQuantity} | Thực tế: ${check.actualQuantity}',
                      ),
                      if (check.note != null && check.note!.isNotEmpty)
                        Text(
                          'Ghi chú: ${check.note}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: check.status == CheckStatus.match
                        ? Colors.green[100]
                        : check.status == CheckStatus.surplus
                            ? Colors.blue[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    check.differenceText,
                    style: TextStyle(
                      color: check.status == CheckStatus.match
                          ? Colors.green[800]
                          : check.status == CheckStatus.surplus
                              ? Colors.blue[800]
                              : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

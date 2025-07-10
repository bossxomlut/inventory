import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/index.dart';
import '../../domain/index.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../../domain/repositories/product/transaction_repository.dart';
import '../../provider/index.dart';
import '../../resources/theme.dart';
import '../../shared_widgets/image/image_present_view.dart';
import '../../shared_widgets/index.dart';
import 'provider/product_detail_provider.dart';
import 'widget/add_product_widget.dart';
import 'widget/index.dart';

@RoutePage()
class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int selectedIndex = 0;

  /// Getter để lấy ID sản phẩm một cách nhất quán
  int get productId => widget.product.id;

  @override
  void initState() {
    super.initState();
    // Khởi tạo provider với ID của sản phẩm
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productDetailProvider(productId).notifier).updateProductData(widget.product);
      ref.read(productDetailProvider(productId).notifier).loadProduct();
    });
  }

  /// Opens the image preview in full screen mode
  void _openImagePreview() {
    final product = ref.watch(productDetailProvider(productId));
    final images = product?.images ?? [];

    if (images.isEmpty || images.first.path == null) return;

    // Extract all valid image paths
    final imagePaths = images.where((img) => img.path != null).map((img) => img.path!).toList();

    if (imagePaths.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ImagePresentView(
          imageUrls: imagePaths,
          initialIndex: selectedIndex,
          deleteMode: false,
        ),
      ),
    );
  }

  /// Opens the edit product screen
  void _openEditProductScreen() {
    EditProductScreen(product: ref.read(productDetailProvider(productId)) ?? widget.product).show(context).whenComplete(
      () {
        ref.read(productDetailProvider(productId).notifier).loadProduct();
      },
    );
  }

  // Method to show barcode bottom sheet
  void _showBarcodeBottomSheet(Product product) {
    final appTheme = context.appTheme;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mã sản phẩm',
                style: appTheme.headingSemibold24Default,
              ),
              const SizedBox(height: 24),
              if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appTheme.colorBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code, size: 24, color: appTheme.colorPrimary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          product.barcode!,
                          style: appTheme.headingSemibold20Default,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép mã sản phẩm vào bộ nhớ đệm')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Sao chép'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: appTheme.colorTextInverse,
                        backgroundColor: appTheme.colorPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng lưu trữ mã sẽ được triển khai sau')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu trữ'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: appTheme.colorTextInverse,
                        backgroundColor: appTheme.colorSecondary,
                      ),
                    ),
                  ],
                ),
              ] else
                const Text('Sản phẩm này không có mã barcode'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productDetail = ref.watch(productDetailProvider(productId));
    final productPrice = ref.watch(productPriceByIdProvider(productId));
    final product = productDetail ?? widget.product;
    final appTheme = context.appTheme;
    final images = product.images ?? [];
    final hasImages = images.isNotEmpty && images.first.path != null;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: appTheme.colorBackground,
      body: RefreshIndicator(
        onRefresh: () => ref.read(productDetailProvider(productId).notifier).loadProduct(),
        child: CustomScrollView(
          slivers: [
            // App bar with image as background
            SliverAppBar(
              expandedHeight: hasImages ? size.width * 0.75 : 200,
              pinned: true,
              stretch: true,
              backgroundColor: appTheme.colorPrimary,
              foregroundColor: appTheme.colorTextInverse,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appTheme.colorTextWhite.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  color: appTheme.colorTextWhite,
                  padding: EdgeInsets.zero,
                  tooltip: 'Quay lại',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: hasImages
                    ? GestureDetector(
                        onTap: _openImagePreview,
                        child: Hero(
                          tag: 'product-image-ÿ{product.id}',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(images[selectedIndex].path!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: appTheme.colorBackgroundSublest,
                                  child: const Icon(Icons.broken_image, size: 64),
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, appTheme.colorDynamicBlack80],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 72,
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: appTheme.headingSemibold24Default.copyWith(
                                        color: appTheme.colorTextWhite,
                                        shadows: [const Shadow(blurRadius: 2.0, color: Colors.black54)],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => _showBarcodeBottomSheet(product),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: appTheme.colorTextWhite.withOpacity(0.3),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.qr_code,
                                                    size: 14,
                                                    color: appTheme.colorTextWhite,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    product.barcode!,
                                                    style: appTheme.textRegular12Default.copyWith(
                                                      color: appTheme.colorTextWhite,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.info_outline,
                                                    size: 14,
                                                    color: appTheme.colorTextWhite,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        color: appTheme.colorPrimary,
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: appTheme.colorTextWhite.withOpacity(0.7),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 72,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: appTheme.headingSemibold24Default.copyWith(
                                      color: appTheme.colorTextWhite,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _showBarcodeBottomSheet(product),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: appTheme.colorTextWhite.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.qr_code,
                                                  size: 14,
                                                  color: appTheme.colorTextWhite,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  product.barcode!,
                                                  style: appTheme.textRegular12Default.copyWith(
                                                    color: appTheme.colorTextWhite,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                titlePadding: EdgeInsets.zero,
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appTheme.colorTextWhite.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: _openEditProductScreen,
                    tooltip: 'Chỉnh sửa sản phẩm',
                    color: appTheme.colorTextWhite,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8, left: 4),
                  decoration: BoxDecoration(
                    color: appTheme.colorTextWhite.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Icons.share, size: 18),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                    tooltip: 'Chia sẻ',
                    color: appTheme.colorTextWhite,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Thumbnails if there are multiple images
            if (hasImages && images.length > 1)
              SliverToBoxAdapter(
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final imageUrl = images[index].path;
                      if (imageUrl == null) return const SizedBox.shrink();

                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedIndex == index ? appTheme.colorPrimary : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: appTheme.colorDynamicBlack80,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.file(
                            File(imageUrl),
                            fit: BoxFit.cover,
                            cacheWidth: 200,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: appTheme.colorBackgroundSublest,
                              child: const Icon(Icons.broken_image, size: 24),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Product details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Inventory status card with price and quantity
                    Container(
                      decoration: BoxDecoration(
                        color: appTheme.colorBackgroundSurface,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Giá',
                                        style: appTheme.textRegular14Default.copyWith(
                                          color: appTheme.colorTextSubtle,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      productPrice.when(
                                        data: (price) {
                                          return Text(
                                            price?.sellingPrice != null
                                                ? '${price.sellingPrice.priceFormat()}'
                                                : 'Chưa có giá',
                                            style: appTheme.headingSemibold24Default.copyWith(
                                              color: price?.sellingPrice != null
                                                  ? appTheme.colorPrimary
                                                  : appTheme.colorTextSubtle,
                                            ),
                                          );
                                        },
                                        error: (error, stackTrace) => Text(
                                          'Lỗi tải giá',
                                          style: appTheme.headingSemibold24Default.copyWith(
                                            color: appTheme.colorError,
                                          ),
                                        ),
                                        loading: () => const CircularProgressIndicator(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: appTheme.colorDivider,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tồn kho',
                                        style: appTheme.textRegular14Default.copyWith(
                                          color: appTheme.colorTextSubtle,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            product.quantity > 0 ? Icons.check_circle : Icons.warning,
                                            size: 20,
                                            color: product.quantity > 0
                                                ? appTheme.colorTextSupportGreen
                                                : appTheme.colorTextSupportRed,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${product.quantity}',
                                            style: appTheme.headingSemibold24Default.copyWith(
                                              color: product.quantity > 0
                                                  ? appTheme.colorTextSupportGreen
                                                  : appTheme.colorTextSupportRed,
                                            ),
                                          ),
                                          if (product.unit != null)
                                            Text(
                                              ' ${product.unit!.name}',
                                              style: appTheme.textMedium14Default.copyWith(
                                                color: appTheme.colorTextSubtle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (product.unit != null || product.category != null)
                              Container(
                                padding: const EdgeInsets.only(top: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: appTheme.colorDivider,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (product.category != null) ...[
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: appTheme.colorSecondary.withOpacity(0.15),
                                            border: Border.all(
                                              color: appTheme.colorSecondary.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: appTheme.colorSecondary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.category_outlined,
                                                  size: 18,
                                                  color: appTheme.colorPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Danh mục',
                                                      style: appTheme.textRegular12Default.copyWith(
                                                        color: appTheme.colorTextSubtle,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      product.category!.name,
                                                      style: appTheme.textMedium15Default,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (product.unit != null && product.category != null) const SizedBox(width: 12),
                                    if (product.unit != null) ...[
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: appTheme.colorSecondary.withOpacity(0.15),
                                            border: Border.all(
                                              color: appTheme.colorSecondary.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: appTheme.colorSecondary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.straighten_outlined,
                                                  size: 18,
                                                  color: appTheme.colorPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Đơn vị',
                                                      style: appTheme.textRegular12Default.copyWith(
                                                        color: appTheme.colorTextSubtle,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      product.unit!.name,
                                                      style: appTheme.headingSemibold20Default.copyWith(
                                                        color: appTheme.colorPrimary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description section if available
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: appTheme.colorPrimary, // was appTheme.primary
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mô tả',
                              style: appTheme.textMedium14Default.copyWith(
                                color: appTheme.colorTextInverse, // was appTheme.onBackground
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: appTheme.colorBackgroundSurface,
                          boxShadow: [
                            BoxShadow(
                              color: appTheme.colorDynamicBlack80,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            product.description!,
                            style: appTheme.textRegular14Default.copyWith(
                              color: appTheme.colorTextSubtle,
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Transaction history placeholder
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 20,
                            color: appTheme.colorPrimary, // correct
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lịch sử giao dịch',
                            style: appTheme.headingSemibold20Default.copyWith(
                              color: appTheme.colorTextDefault, // correct property
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer(
                      builder: (BuildContext context, WidgetRef ref, Widget? child) {
                        final transactionRepo = ref.watch(getTransactionsByProductIdProvider(productId));
                        return transactionRepo.map(
                            data: (AsyncData<List<Transaction>> data) {
                              if (data.value.isEmpty) {
                                return const Center(child: Text('Chưa có giao dịch nào'));
                              }

                              final transactions = data.value!;
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: transactions.length,
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  return ColoredBox(
                                    color: appTheme.colorBackgroundSurface,
                                    child: ListTile(
                                      leading: getTransactionIcon(transaction.type, appTheme),
                                      title: Text(
                                        '${transaction.category.displayName}',
                                        style: appTheme.textRegular14Default.copyWith(
                                          color: appTheme.colorTextDefault,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${transaction.timestamp.timeAgo}',
                                            style: appTheme.textRegular12Default.copyWith(
                                              color: appTheme.colorTextSubtle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 100,
                                        ),
                                        child: QuantityWidget(quantity: transaction.quantity),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) => AppDivider(),
                              );
                            },
                            error: (AsyncError<List<Transaction>> error) => Center(child: Text('Lỗi: ${error.error}')),
                            loading: (AsyncLoading<List<Transaction>> loading) =>
                                const Center(child: CircularProgressIndicator()));
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTransactionIcon(TransactionType transaction, AppThemeData appTheme) {
    switch (transaction) {
      case TransactionType.increase:
        return Icon(
          Icons.add_circle_outline,
          color: appTheme.colorTextSupportGreen,
        );
      case TransactionType.decrease:
        return Icon(
          Icons.remove_circle_outline,
          color: appTheme.colorTextSupportRed,
        );
      case TransactionType.balance:
        return Icon(
          Icons.check_circle_outlined,
          color: appTheme.colorTextSupportBlue,
        );
    }
  }
}

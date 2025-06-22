import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/index.dart';
import '../../shared_widgets/image/image_present_view.dart';
import '../../shared_widgets/index.dart';
import 'provider/product_detail_provider.dart';
import 'widget/add_product_widget.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code, size: 24, color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          product.barcode!,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
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
                        // Copy to clipboard
                        // This would typically use Clipboard.setData
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép mã sản phẩm vào bộ nhớ đệm')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Sao chép'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.primary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Save or share functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng lưu trữ mã sẽ được triển khai sau')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu trữ'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.onSecondary,
                        backgroundColor: colorScheme.secondary,
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
    // Theo dõi thông tin sản phẩm từ provider
    final productDetail = ref.watch(productDetailProvider(productId));

    // Sử dụng thông tin sản phẩm từ provider nếu có, nếu không thì dùng product từ widget
    final product = productDetail ?? widget.product;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final images = product.images ?? [];
    final hasImages = images.isNotEmpty && images.first.path != null;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => ref.read(productDetailProvider(productId).notifier).loadProduct(),
        child: CustomScrollView(
          slivers: [
            // App bar with image as background
            SliverAppBar(
              expandedHeight: hasImages ? size.width * 0.75 : 200,
              pinned: true,
              stretch: true,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              leading: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: hasImages ? Colors.white.withOpacity(0.3) : colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                  color: hasImages ? Colors.white : colorScheme.onPrimaryContainer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: hasImages
                    ? GestureDetector(
                        onTap: _openImagePreview,
                        child: Hero(
                          tag: 'product-image-${product.id}',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(images[selectedIndex].path!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 64),
                                ),
                              ),
                              // Gradient overlay for better text visibility
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black54],
                                  ),
                                ),
                              ),
                              // Add product name overlay at the bottom of the image
                              Positioned(
                                left: 16,
                                right: 72, // Leave space for action buttons
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                                                color: Colors.white.withOpacity(0.3),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.qr_code,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    product.barcode!,
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.info_outline,
                                                    size: 14,
                                                    color: Colors.white,
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
                        color: colorScheme.primary,
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 72, // Leave space for action buttons
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
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
                                              color: colorScheme.onPrimary.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.qr_code,
                                                  size: 14,
                                                  color: colorScheme.onPrimary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  product.barcode!,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onPrimary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.info_outline,
                                                  size: 14,
                                                  color: colorScheme.onPrimary,
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
                // Remove the title property to avoid duplication
                titlePadding: EdgeInsets.zero,
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: hasImages ? Colors.white.withOpacity(0.3) : colorScheme.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: _openEditProductScreen,
                    tooltip: 'Chỉnh sửa',
                    color: hasImages ? Colors.white : colorScheme.onPrimaryContainer,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: hasImages ? Colors.white.withOpacity(0.3) : colorScheme.primaryContainer.withOpacity(0.3),
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
                    color: hasImages ? Colors.white : colorScheme.onPrimaryContainer,
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
                              color: selectedIndex == index ? colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                              color: Colors.grey[300],
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
                      color: Colors.white,
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
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.price != null ? '${product.price} đ' : 'Chưa có giá',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey[300],
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tồn kho',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            product.quantity > 0 ? Icons.check_circle : Icons.warning,
                                            size: 20,
                                            color: product.quantity > 0 ? Colors.green : Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${product.quantity}',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: product.quantity > 0 ? Colors.green : Colors.orange,
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
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.only(top: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (product.unit != null) ...[
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primaryContainer,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.straighten,
                                                  size: 18,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Đơn vị',
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      product.unit!.name,
                                                      style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: colorScheme.primary,
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
                                    
                                    if (product.unit != null && product.category != null)
                                      const SizedBox(width: 12),
                                      
                                    if (product.category != null) ...[
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorScheme.secondaryContainer.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.secondaryContainer,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.category,
                                                  size: 18,
                                                  color: colorScheme.secondary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Danh mục',
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      product.category!.name,
                                                      style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: colorScheme.secondary,
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
                      Text(
                        'Mô tả',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            product.description!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                    
                    // Inventory action buttons
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.add_shopping_cart,
                            label: 'Nhập kho',
                            color: Colors.green,
                            onTap: () {
                              // TODO: Implement stock-in functionality
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.remove_shopping_cart,
                            label: 'Xuất kho',
                            color: Colors.orange,
                            onTap: () {
                              // TODO: Implement stock-out functionality
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // Transaction history placeholder
                    const SizedBox(height: 24),                      Text(
                        'Lịch sử giao dịch',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        color: Colors.white,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3, // Placeholder transaction count
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            // This is just a placeholder for transaction history
                            // In a real app, you would fetch actual transaction data
                            final isStockIn = index % 2 == 0;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isStockIn ? Colors.green[100] : Colors.orange[100],
                                child: Icon(
                                  isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isStockIn ? Colors.green : Colors.orange,
                                ),
                              ),
                              title: Text(isStockIn ? 'Nhập kho' : 'Xuất kho'),
                              subtitle: Text('Số lượng: ${(index + 1) * 5}'),
                              trailing: Text(
                                '${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().subtract(Duration(days: index)).month}/${DateTime.now().subtract(Duration(days: index)).year}',
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
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

  // Helper method to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: const RoundedRectangleBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

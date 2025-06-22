import 'dart:io';

import 'package:auto_route/auto_route.dart';
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
    final product = widget.product;
    final images = product.images ?? [];

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

  @override
  Widget build(BuildContext context) {
    // Theo dõi thông tin sản phẩm từ provider
    final productDetail = ref.watch(productDetailProvider(productId));

    // Sử dụng thông tin sản phẩm từ provider nếu có, nếu không thì dùng product từ widget
    final product = productDetail ?? widget.product;
    final theme = Theme.of(context);
    final images = product.images ?? [];
    final hasImages = images.isNotEmpty && images.first.path != null;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productDetailProvider(productId).notifier).loadProduct(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main product image - full width
              if (hasImages)
                GestureDetector(
                  onTap: _openImagePreview,
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: Container(
                      width: size.width,
                      height: size.width * 0.75, // 4:3 aspect ratio
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Image.file(
                        File(images[selectedIndex].path!),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: size.width,
                  height: size.width * 0.75,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                ),

              // Thumbnails if there are multiple images
              if (hasImages && images.length > 1)
                Container(
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
                              color: selectedIndex == index ? theme.colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 24),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Product details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product name
                    Text(product.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Product details in card
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Category
                            if (product.category != null)
                              _buildInfoRow(Icons.category, 'Danh mục', product.category!.name),

                            // Unit
                            if (product.unit != null) _buildInfoRow(Icons.straighten, 'Đơn vị', product.unit!.name),

                            // Barcode/SKU
                            if (product.barcode != null && product.barcode!.isNotEmpty)
                              _buildInfoRow(Icons.qr_code, 'Mã sản phẩm', product.barcode!),

                            // Price
                            if (product.price != null) _buildInfoRow(Icons.attach_money, 'Giá', '${product.price} đ'),

                            // Quantity
                            _buildInfoRow(Icons.inventory_2, 'Số lượng', '${product.quantity}'),
                          ],
                        ),
                      ),
                    ),

                    // Description section if available
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Mô tả', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            product.description!,
                            style: theme.textTheme.bodyMedium,
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
      // Floating edit button
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditProductScreen,
        child: const Icon(Icons.edit),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

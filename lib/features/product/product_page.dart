import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/product/inventory.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/index.dart';
import 'provider/product_filter_provider.dart';
import 'provider/product_provider.dart';
import 'widget/add_product_widget.dart';
import 'widget/index.dart';

@RoutePage()
class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to search controller changes
    _searchController.addListener(() {
      ref.watch(textSearchProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortType = ref.watch(productSortTypeProvider);
    final categoryFilter = ref.watch(productCategoryFilterProvider);
    final isSearchVisible = ref.watch(isSearchVisibleProvider);

    // Check if any filters are active
    final bool hasActiveFilters = sortType != ProductSortType.none || categoryFilter != null;

    return Scaffold(
      appBar: isSearchVisible
          ? AppBar(
              // Custom search AppBar
              backgroundColor: Theme.of(context).colorScheme.primary,
              leading: InkWell(
                child: const Icon(Icons.close, color: Colors.white),
                onTap: () {
                  ref.read(isSearchVisibleProvider.notifier).state = false;
                  ref.read(textSearchProvider.notifier).state = '';
                  _searchController.clear();
                },
              ),
              titleSpacing: 0,
              centerTitle: false,
              title: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    suffix: AnimatedBuilder(
                        animation: _searchController,
                        builder: (context, _) {
                          final isNotEmpty = _searchController.text.isNotEmpty;
                          if (!isNotEmpty) {
                            return const SizedBox.shrink();
                          }
                          return InkWell(
                            onTap: () {
                              _searchController.clear();
                              ref.read(textSearchProvider.notifier).state = '';
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.clear,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          );
                        })),
                autofocus: true,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
              ),
              actions: [
                Builder(builder: (context) {
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: hasActiveFilters,
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    tooltip: 'Lọc sản phẩm',
                  );
                }),
              ],
            )
          : CustomAppBar(
              title: 'Sản phẩm',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    ref.read(isSearchVisibleProvider.notifier).state = true;
                    // Đảm bảo focus vào text field và mở bàn phím
                    Future.delayed(const Duration(milliseconds: 50), () {
                      FocusScope.of(context).requestFocus(_searchFocusNode);
                    });
                  },
                  tooltip: 'Tìm kiếm',
                ),
                Builder(builder: (context) {
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: hasActiveFilters,
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    tooltip: 'Lọc sản phẩm',
                  );
                }),
              ],
            ),
      endDrawer: const ProductFilterDrawer(),
      body: Column(
        children: [
          Expanded(child: const _ProductListView()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          const AddProductScreen().show(context);
        },
      ),
    );
  }
}

// Implement a full-featured ProductDetailScreen to display product images, name, category, barcode, price, quantity, and description in a modern layout.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final images = product.images ?? [];
    final hasImages = images.isNotEmpty && images.first.path != null;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master image
            if (hasImages)
              Center(
                child: Hero(
                  tag: 'product-image-${product.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(images[selectedIndex].path!),
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 260,
                        height: 260,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 64),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
            if (hasImages && images.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final imageUrl = images[index].path;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedIndex == index ? theme.colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imageUrl!),
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 64,
                                height: 64,
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
              ),
            const SizedBox(height: 24),
            // Product name
            Text(product.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Category
            if (product.category != null)
              Row(
                children: [
                  const Icon(Icons.category, size: 20),
                  const SizedBox(width: 8),
                  Text(product.category!.name, style: theme.textTheme.bodyLarge),
                ],
              ),
            const SizedBox(height: 12),
            // Barcode
            if (product.barcode != null && product.barcode!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 20),
                  const SizedBox(width: 8),
                  Text(product.barcode!, style: theme.textTheme.bodyLarge),
                ],
              ),
            const SizedBox(height: 12),
            // Price
            if (product.price != null)
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 20),
                  const SizedBox(width: 8),
                  Text('${product.price}', style: theme.textTheme.bodyLarge),
                ],
              ),
            const SizedBox(height: 12),
            // Quantity
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 20),
                const SizedBox(width: 8),
                Text('In stock: ${product.quantity}', style: theme.textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 24),
            // Description
            if (product.description != null && product.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(product.description!, style: theme.textTheme.bodyMedium),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductListView extends StatefulHookConsumerWidget {
  const _ProductListView({super.key});

  @override
  ConsumerState createState() => __ProductListViewState();
}

class __ProductListViewState extends ConsumerState<_ProductListView> {
  @override
  void initState() {
    super.initState();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadProductProvider.notifier).loadData(query: LoadListQuery(page: 1, pageSize: 20));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use loadProductProvider directly
    final products = ref.watch(loadProductProvider);
    final sortType = ref.watch(productSortTypeProvider);
    final categoryFilter = ref.watch(productCategoryFilterProvider);
    final searchQuery = ref.watch(textSearchProvider);

    ref.listen(
      productFilterProvider,
      (previous, next) {
        ref.read(loadProductProvider.notifier).listenFilterChanges();
      },
    );
    if (products.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (products.hasError) {
      return Center(child: Text('Error: ${products.error}'));
    } else if (products.isEmpty) {
      if (searchQuery.isNotEmpty || sortType != ProductSortType.none || categoryFilter != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy sản phẩm nào',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(textSearchProvider.notifier).state = '';
                  ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
                  ref.read(productCategoryFilterProvider.notifier).state = null;
                },
                child: const Text('Xóa bộ lọc'),
              ),
            ],
          ),
        );
      }
      return const EmptyItemWidget();
    } else {
      // Show active filters if any
      final bool hasActiveFilters = sortType != ProductSortType.none || categoryFilter != null;

      final length = products.data.length;
      return Column(
        children: [
          // Show active filters bar
          if (hasActiveFilters)
            Container(
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            if (sortType != ProductSortType.none)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text('Sắp xếp: ${sortType.displayName}'),
                                  onDeleted: () {
                                    ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
                                  },
                                ),
                              ),
                            if (categoryFilter != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text('Danh mục: ${categoryFilter.name}'),
                                  onDeleted: () {
                                    ref.read(productCategoryFilterProvider.notifier).state = null;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
                          ref.read(productCategoryFilterProvider.notifier).state = null;
                        },
                        child: const Text('Xóa tất cả'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Product list
          Expanded(
            child: ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: products.isLoadingMore ? length + 1 : length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (products.isLoadingMore && index == length) {
                  return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
                }

                final product = products.data[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    // Navigate to product detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute<ProductDetailScreen>(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
            ),
          ),
        ],
      );
    }
  }
}

class EmptyItemWidget extends StatelessWidget {
  const EmptyItemWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No products found.'));
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/inventory.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/index.dart';
import 'provider/product_provider.dart';
import 'widget/add_product_widget.dart';
import 'widget/index.dart';

@RoutePage()
class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the product list from the provider (default isOutOfStock: false)
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const _ProductListView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          AddProductScreen().show(context);
        },
      ),
    );
  }
}

// Placeholder for product detail screen
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Center(child: Text('Product Details: ${product.name}')),
    );
  }
}

class _ProductListView extends ConsumerStatefulWidget {
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
    final products = ref.watch(loadProductProvider);
    if (products.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (products.hasError) {
      return Center(child: Text('Error: ${products.error}'));
    } else if (products.isEmpty) {
      return const EmptyItemWidget();
    } else {
      //add loading if have loadmore

      final length = products.data.length;
      return ListView.builder(
        itemCount: products.isLoadingMore ? length + 1 : length,
        itemBuilder: (context, index) {
          if (products.isLoadingMore && index == length) {
            return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
          }

          final product = products.data[index];
          return ProductCard(
            product: product,
            onTap: () {
              // Navigate to product detail screen (placeholder)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          );
        },
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

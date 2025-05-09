import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/inventory.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/bottom_sheet.dart';
import 'provider/product_provider.dart';
import 'widget/index.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the product list from the provider (default isOutOfStock: false)
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: PageView(
        children: [
          const _ProductListView(),
          const __ProductListView2(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final products = ref.read(loadProductProvider.notifier);
          products.loadData(query: const LoadListQuery(page: 1, pageSize: 10));

          // AddProductScreen().show(context);
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

// Add product bottom sheet
class AddProductScreen extends ConsumerWidget with ShowBottomSheet {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AddProductForm(),
        ],
      ),
    );
  }
}

// Form for adding a product
class AddProductForm extends HookWidget {
  const AddProductForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the form state from the provider
    final _nameController = useTextEditingController();
    final _quantityController = useTextEditingController();
    final _priceController = useTextEditingController();
    final _categoryController = useTextEditingController();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              // Image placeholder
              Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    return ElevatedButton(
                      onPressed: () {
                        // Create a new product
                        final name = _nameController.text.trim();
                        final quantityStr = _quantityController.text.trim();
                        final priceStr = _priceController.text.trim();
                        final category = _categoryController.text.trim();

                        // Validate inputs
                        if (name.isEmpty || quantityStr.isEmpty || priceStr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all required fields')),
                          );
                          return;
                        }

                        final quantity = int.tryParse(quantityStr) ?? 0;
                        final price = double.tryParse(priceStr) ?? 0.0;

                        final newProduct = Product(
                          id: const Uuid().v4(), // Generate unique ID
                          name: name,
                          description: '',
                          price: price,
                          imageUrl: '', // Placeholder for image
                          quantity: quantity,
                          categoryId: category.isEmpty ? 'default' : category,
                          barcode: '',
                        );

                        // Add product to the provider
                        ref.read(loadProductProvider.notifier).add(newProduct);

                        // Close bottom sheet
                        Navigator.pop(context);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product added successfully')),
                        );
                      },
                      child: const Text('Save'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListView extends ConsumerWidget {
  const _ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class __ProductListView2 extends ConsumerStatefulWidget {
  const __ProductListView2({super.key});

  @override
  ConsumerState createState() => ___ProductListView2State();
}

class ___ProductListView2State extends ConsumerState<__ProductListView2> {
  @override
  void initState() {
    super.initState();
    //add post call back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadProductProvider.notifier).loadData(query: const LoadListQuery(page: 1, pageSize: 10));
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
      return const Center(child: Text('No products found.'));
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/index.dart';
import 'widget/index.dart';

final productListProvider = StateProvider<List<Product>>((ref) => [
      Product(
        id: '1',
        name: 'Laptop',
        price: 999.99,
        quantity: 10,
        categoryId: 'electronics',
        imageUrl: 'https://example.com/laptop.jpg',
      ),
    ]);

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              // Điều hướng đến màn hình chi tiết
            },
          );
        },
      ),
    );
  }
}

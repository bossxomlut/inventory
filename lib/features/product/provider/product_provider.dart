import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/inventory.dart';

part 'product_provider.g.dart';

@riverpod
class ProductProvider extends _$ProductProvider {
  @override
  List<Product> build() {
    // Initialize with an empty list or fetch initial data
    return [];
  }

  void addProduct(Product product) {
    state = [...state, product];
  }

  void removeProduct(String productId) {
    state = state.where((product) => product.id != productId).toList();
  }

  void updateProduct(Product updatedProduct) {
    state = state.map((product) {
      return product.id == updatedProduct.id ? updatedProduct : product;
    }).toList();
  }
}

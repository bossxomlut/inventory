import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/notification.dart';
//
// /// Provider quản lý thông tin chi tiết của sản phẩm
// final productDetailProvider = AutoDisposeNotifierProviderFamily<ProductDetailNotifier, Product?, int>(
//     (productId) => ProductDetailNotifier(ref, productId));
// }

final productDetailProvider =
    AutoDisposeNotifierProviderFamily<ProductDetailNotifier, Product?, int>(() => ProductDetailNotifier());

/// StateNotifier để quản lý trạng thái chi tiết sản phẩm
class ProductDetailNotifier extends AutoDisposeFamilyNotifier<Product?, int> {
  /// Tải thông tin sản phẩm từ repository
  Future<void> loadProduct() async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final product = await productRepo.read(arg);
      state = product;
    } catch (e) {
      ref.read(notificationProvider.notifier).showError('Không thể tải thông tin sản phẩm: ${e.toString()}');
    } finally {}
  }

  /// Cập nhật thông tin sản phẩm trong state
  void updateProductData(Product updatedProduct) {
    state = updatedProduct;
  }

  @override
  Product? build(int arg) {
    loadProduct();
    return null;
  }
}

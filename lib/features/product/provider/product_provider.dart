import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/inventory.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../provider/load_list.dart';
import '../../../shared_widgets/toast.dart';

final loadProductProvider = AutoDisposeNotifierProvider<LoadProductController, LoadListState<Product>>(() {
  return LoadProductController.new();
});

class LoadProductController extends LoadListController<Product> {
  @override
  Future<List<Product>> fetchData(LoadListQuery query) {
    final productRepo = ref.watch(productRepositoryProvider);
    return productRepo.search(query.search ?? '', query.page, query.pageSize);
  }

  //create a product
  void createProduct(Product product) async {
    try {
      final productRepo = ref.watch(productRepositoryProvider);
      final newProduct = await productRepo.create(product);
      state = state.copyWith(data: [...state.data, newProduct]);
      showSuccess(message: 'Add new product successfully');
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Add new product failed');
    }
  }

  //update a product
  void updateProduct(Product product) async {
    try {
      final productRepo = ref.watch(productRepositoryProvider);
      final updatedProduct = await productRepo.update(product);
      state = state.copyWith(
        data: state.data.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList(),
      );
      showSuccess(message: 'Update product successfully');
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Update product failed');
    }
  }
}

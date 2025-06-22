import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../routes/app_router.dart';
import '../../category/provider/category_provider.dart';
import '../../unit/provider/unit_filter_provider.dart';
import 'product_filter_provider.dart';

final loadProductProvider = AutoDisposeNotifierProvider<LoadProductController, LoadListState<Product>>(() {
  return LoadProductController.new();
});

class LoadProductController extends LoadListController<Product> with CommonProvider<LoadListState<Product>> {
  //create a method to listen filter changes to call reload data

  void listenFilterChanges() {
    refresh();
  }

  @override
  Future<LoadResult<Product>> fetchData(LoadListQuery query) {
    final productRepo = ref.read(productRepositoryProvider);

    // Tạo filter từ các bộ lọc đã chọn
    final filter = ref.read(productFilterProvider);

    final search = filter['search'] as String? ?? '';

    print('Search query: $search');

    // Truyền filter xuống repository
    return productRepo.search(search, query.page, query.pageSize, filter: filter);
  }

  //create a product
  Future<void> createProduct(Product product) async {
    try {
      showLoading();
      final productRepo = ref.read(productRepositoryProvider);

      // Gọi repository để tạo sản phẩm (bao gồm xử lý ảnh)
      final created = await productRepo.create(product);
      state = state.copyWith(data: [...state.data, created]);

      // Clear all filters and set "Created today" filter
      ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
      ref.read(multiSelectCategoryProvider.notifier).clear();
      ref.read(multiSelectUnitProvider.notifier).clear();
      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
      // Set created time filter to "today"
      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.today;
      ref.read(activeTimeFilterTypeProvider.notifier).state = 'created';
      // Clear search text
      ref.read(textSearchProvider.notifier).state = '';

      showSuccess('Add new product successfully');
      appRouter.popForced();
    } catch (e) {
      //log error
      print('Error creating product: $e');
      // Handle error
      state = state.copyWith(error: e.toString());
      showError('Add new product failed');
    } finally {
      hideLoading();
    }
  }

  //update a product
  Future<void> updateProduct(Product product) async {
    try {
      showLoading();
      final productRepo = ref.read(productRepositoryProvider);
      // Gọi repository để cập nhật sản phẩm (bao gồm xử lý ảnh)
      final updatedProduct = await productRepo.update(product);
      state = state.copyWith(
        data: state.data.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList(),
      );
      showSuccess('Update product successfully');
    } catch (e, st) {
      log('An error occurred while updating product: $e', stackTrace: st);
      // Handle error
      state = state.copyWith(error: e.toString());
      showError('Update product failed');
    } finally {
      hideLoading();
    }
  }
}

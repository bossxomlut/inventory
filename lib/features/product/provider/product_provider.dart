import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../domain/repositories/product/transaction_repository.dart';
import '../../../domain/repositories/product/update_product_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../routes/app_router.dart';
import '../../../shared_widgets/index.dart';
import '../../category/provider/category_provider.dart';
import '../../unit/provider/unit_filter_provider.dart';
import 'product_filter_provider.dart';

part 'product_provider.g.dart';

@riverpod
class LoadProduct extends _$LoadProduct with LoadListController<Product>, CommonProvider<LoadListState<Product>> {
  //create a method to listen filter changes to call reload data

  @override
  LoadListState<Product> build() {
    ref.listen(
      productFilterProvider,
      (previous, next) {
        refresh();
      },
    );
    Future(refresh);
    return LoadListState<Product>.initial();
  }

  @override
  Future<LoadResult<Product>> fetchData(LoadListQuery query) {
    final productRepo = ref.read(productRepositoryProvider);

    // Tạo filter từ các bộ lọc đã chọn
    final filter = ref.read(productFilterProvider);

    final search = filter['search'] as String? ?? '';

    // Truyền filter xuống repository
    return productRepo.search(search, query.page, query.pageSize, filter: filter);
  }

  //create a product
  Future<void> createProduct(Product product) async {
    try {
      showLoading();

      // Gọi repository để tạo sản phẩm (bao gồm xử lý ảnh)
      final created = await ref.read(updateProductRepositoryProvider).createProduct(product);

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

      hideLoading();

      showSuccess('Thêm sản phẩm mới thành công');
      appRouter.popForced();
    } catch (e) {
      hideLoading();

      // Lấy context từ appRouter và sử dụng mixin ShowDialog với cấu hình
      final context = appRouter.context;
      if (context != null) {
        // Tạo và hiển thị dialog lỗi sử dụng mixin ShowDialog
        await ErrorDetailsDialog(
          title: 'Lỗi tạo sản phẩm',
          message: 'Không thể tạo sản phẩm mới. Vui lòng thử lại.',
          details: e.toString(),
          buttonText: 'Đóng',
          barrierDismissible: false, // Không cho phép tap outside để đóng
        ).show(context, barrierDismissible: false);
      } else {
        // Fallback nếu không có context
        showError('Thêm sản phẩm mới thất bại: ${e.toString()}');
      }
    } finally {}
  }

  //update a product
  Future<void> updateProduct(Product product, int currentQuantity) async {
    try {
      showLoading();
      // Gọi repository để cập nhật sản phẩm (bao gồm xử lý ảnh)
      final updatedProduct = await ref.read(updateProductRepositoryProvider).updateProduct(product, TransactionCategory.update);

      ref.invalidate(getTransactionsByProductIdProvider(updatedProduct.id));

      state = state.copyWith(
        data: state.data.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList(),
      );
      hideLoading();

      showSuccess('Cập nhật sản phẩm thành công');
    } catch (e, st) {
      hideLoading();

      log('An error occurred while updating product: $e', stackTrace: st);

      // Lấy context từ appRouter và sử dụng mixin ShowDialog với cấu hình
      final context = appRouter.context;
      if (context != null) {
        // Tạo và hiển thị dialog lỗi sử dụng mixin ShowDialog
        Future(() {
          return ErrorDetailsDialog(
            title: 'Lỗi cập nhật sản phẩm',
            message: 'Không thể cập nhật sản phẩm. Vui lòng thử lại.',
            details: e.toString(),
            buttonText: 'Đóng',
            barrierDismissible: false, // Không cho phép tap outside để đóng
          ).show(context, barrierDismissible: false);
        });
      } else {
        // Fallback nếu không có context
        showError('Cập nhật sản phẩm thất bại: ${e.toString()}');
      }
    } finally {}
  }
}

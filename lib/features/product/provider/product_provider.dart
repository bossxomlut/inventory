import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
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
class LoadProduct extends _$LoadProduct
    with LoadListController<Product>, CommonProvider<LoadListState<Product>> {
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
    return productRepo.search(search, query.page, query.pageSize,
        filter: filter);
  }

  //create a product
  Future<void> createProduct(Product product) async {
    try {
      showLoading();

      // Gọi repository để tạo sản phẩm (bao gồm xử lý ảnh)
      final created = await ref
          .read(updateProductRepositoryProvider)
          .createProduct(product);

      state = state.copyWith(data: [...state.data, created]);

      // Clear all filters and set "Created today" filter
      ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
      ref.read(multiSelectCategoryProvider.notifier).clear();
      ref.read(multiSelectUnitProvider.notifier).clear();
      ref.read(updatedTimeFilterTypeProvider.notifier).state =
          TimeFilterType.none;
      // Set created time filter to "today"
      ref.read(createdTimeFilterTypeProvider.notifier).state =
          TimeFilterType.today;
      ref.read(activeTimeFilterTypeProvider.notifier).state = 'created';
      // Clear search text
      ref.read(textSearchProvider.notifier).state = '';

      hideLoading();

      final successContext = appRouter.context;
      final successMessage = successContext != null
          ? LKey.productCreateSuccess.tr(context: successContext)
          : LKey.productCreateSuccess.tr();
      showSuccess(successMessage);
      appRouter.popForced();
    } catch (e) {
      hideLoading();

      // Lấy context từ appRouter và sử dụng mixin ShowDialog với cấu hình
      final context = appRouter.context;
      if (context != null) {
        // Tạo và hiển thị dialog lỗi sử dụng mixin ShowDialog
        await ErrorDetailsDialog(
          title: LKey.productCreateErrorTitle.tr(context: context),
          message: LKey.productCreateErrorMessage.tr(context: context),
          details: e.toString(),
          buttonText: LKey.buttonOke.tr(context: context),
          barrierDismissible: false, // Không cho phép tap outside để đóng
        ).show(context, barrierDismissible: false);
      } else {
        // Fallback nếu không có context
        final fallbackMessage = context != null
            ? LKey.productCreateErrorFallback.tr(
                context: context,
                namedArgs: {'error': e.toString()},
              )
            : LKey.productCreateErrorFallback.tr(
                namedArgs: {'error': e.toString()},
              );
        showError(fallbackMessage);
      }
    } finally {}
  }

  //update a product
  Future<void> updateProduct(Product product, int currentQuantity) async {
    try {
      showLoading();
      // Gọi repository để cập nhật sản phẩm (bao gồm xử lý ảnh)
      final updatedProduct = await ref
          .read(updateProductRepositoryProvider)
          .updateProduct(product, TransactionCategory.update);

      ref.invalidate(getTransactionsByProductIdProvider(updatedProduct.id));

      state = state.copyWith(
        data: state.data
            .map((p) => p.id == updatedProduct.id ? updatedProduct : p)
            .toList(),
      );
      hideLoading();

      final successContext = appRouter.context;
      final successMessage = successContext != null
          ? LKey.productUpdateSuccess.tr(context: successContext)
          : LKey.productUpdateSuccess.tr();
      showSuccess(successMessage);
    } catch (e, st) {
      hideLoading();

      log('An error occurred while updating product: $e', stackTrace: st);

      // Lấy context từ appRouter và sử dụng mixin ShowDialog với cấu hình
      final context = appRouter.context;
      if (context != null) {
        // Tạo và hiển thị dialog lỗi sử dụng mixin ShowDialog
        Future(() {
          return ErrorDetailsDialog(
            title: LKey.productUpdateErrorTitle.tr(context: context),
            message: LKey.productUpdateErrorMessage.tr(context: context),
            details: e.toString(),
            buttonText: LKey.buttonOke.tr(context: context),
            barrierDismissible: false, // Không cho phép tap outside để đóng
          ).show(context, barrierDismissible: false);
        });
      } else {
        // Fallback nếu không có context
        final fallbackContext = appRouter.context;
        final fallbackMessage = fallbackContext != null
            ? LKey.productUpdateErrorFallback.tr(
                context: fallbackContext,
                namedArgs: {'error': e.toString()},
              )
            : LKey.productUpdateErrorFallback.tr(
                namedArgs: {'error': e.toString()},
              );
        showError(fallbackMessage);
      }
    } finally {}
  }
}

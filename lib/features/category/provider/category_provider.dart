import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../shared_widgets/toast.dart';

part 'category_provider.g.dart';

@riverpod
class LoadCategory extends _$LoadCategory with LoadListController<Category> {
  @override
  LoadListState<Category> build() {
    return LoadListState<Category>.initial();
  }

  @override
  Future<LoadResult<Category>> fetchData(LoadListQuery query) {
    final repo = ref.read(categoryRepositoryProvider);
    return repo.search(query.search ?? '', query.page, query.pageSize);
  }

  //remove category
  void removeCategory(Category category) async {
    try {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.delete(category);
      state = state.copyWith(
        data: state.data.where((c) => c.id != category.id).toList(),
      );
      showSuccess(message: 'Xóa danh mục thành công');
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Xóa danh mục thất bại');
    }
  }

  //remove multiple categories
  void removeMultipleCategories() async {
    try {
      List<Category> categories = ref.read(multiSelectCategoryProvider).data.toList();

      if (categories.isEmpty) {
        showSimpleInfo(message: 'Chưa chọn danh mục nào');
        return;
      }

      final repo = ref.read(categoryRepositoryProvider);
      // use the removeCategory
      for (final category in categories) {
        await repo.delete(category);
      }
      state = state.copyWith(
        data: state.data.where((c) => !categories.any((cat) => cat.id == c.id)).toList(),
      );
      showSuccess(message: 'Xóa các danh mục thành công');

      ref.read(multiSelectCategoryProvider.notifier).clear();
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Xóa các danh mục thất bại');
    }
  }

  Future<Category?> addCategory(Category category) async {
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final newCategory = await repo.create(category);
      state = state.copyWith(data: [newCategory, ...state.data]);
      showSuccess(message: 'Thêm danh mục thành công');
      return newCategory;
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Thêm danh mục thất bại');
    }
  }

  Future updateCategory(Category category) async {
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final updatedCategory = await repo.update(category);
      state = state.copyWith(
        data: state.data.map((c) => c.id == updatedCategory.id ? updatedCategory : c).toList(),
      );
      showSuccess(message: 'Cập nhật danh mục thành công');
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Cập nhật danh mục thất bại');
    }
  }
}

final multiSelectCategoryProvider =
    AutoDisposeNotifierProvider<MultipleSelectController<Category>, MultipleSelectState<Category>>(() {
  return MultipleSelectController<Category>();
});

//create a provider get all categories
final allCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getAll();
});

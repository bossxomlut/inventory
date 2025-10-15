import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../resources/index.dart';
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
      showSuccess(message: LKey.categoryDeleteSuccess.tr());
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: LKey.categoryDeleteError.tr());
    }
  }

  //remove multiple categories
  void removeMultipleCategories() async {
    try {
      List<Category> categories = ref.read(multiSelectCategoryProvider).data.toList();

      if (categories.isEmpty) {
        showSimpleInfo(message: LKey.categoryNoSelection.tr());
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
      showSuccess(message: LKey.categoryBulkDeleteSuccess.tr());

      ref.read(multiSelectCategoryProvider.notifier).clear();
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: LKey.categoryBulkDeleteError.tr());
    }
  }

  Future<Category?> addCategory(Category category) async {
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final newCategory = await repo.create(category);
      state = state.copyWith(data: [newCategory, ...state.data]);
      showSuccess(message: LKey.categoryCreateSuccess.tr());
      return newCategory;
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: LKey.categoryCreateError.tr());
    }
  }

  Future updateCategory(Category category) async {
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final updatedCategory = await repo.update(category);
      state = state.copyWith(
        data: state.data.map((c) => c.id == updatedCategory.id ? updatedCategory : c).toList(),
      );
      showSuccess(message: LKey.categoryUpdateSuccess.tr());
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: LKey.categoryUpdateError.tr());
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

import 'package:riverpod/riverpod.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../shared_widgets/toast.dart';

final categoryProvider = AutoDisposeNotifierProvider<CategoryController, LoadListState<Category>>(() {
  return CategoryController();
});

class CategoryController extends LoadListController<Category> {
  @override
  Future<List<Category>> fetchData(LoadListQuery query) {
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
      showSuccess(message: 'Category deleted successfully');
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Failed to delete category');
    }
  }

  //remove multiple categories
  void removeMultipleCategories() async {
    try {
      List<Category> categories = ref.read(multiSelectCategoryProvider).data.toList();

      if (categories.isEmpty) {
        showSimpleInfo(message: 'No categories selected');
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
      showSuccess(message: 'Categories deleted successfully');

      ref.read(multiSelectCategoryProvider.notifier).clear();
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Failed to delete categories');
    }
  }

  Future<Category?> addCategory(Category category) async {
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final newCategory = await repo.create(category);
      state = state.copyWith(data: [newCategory, ...state.data]);
      showSuccess(message: 'Add new category successfully');
      return newCategory;
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Add new category failed');
    }
  }

  Future updateCategory(Category category) async {
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final updatedCategory = await repo.update(category);
      state = state.copyWith(
        data: state.data.map((c) => c.id == updatedCategory.id ? updatedCategory : c).toList(),
      );
      showSuccess(message: 'Update category successfully');
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError(message: 'Update category failed');
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

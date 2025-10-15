import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../provider/mixin.dart';
import '../../../resources/index.dart';
import 'unit_filter_provider.dart';

part 'unit_provider.g.dart';

@riverpod
class LoadUnit extends _$LoadUnit with LoadListController<Unit>, CommonProvider<LoadListState<Unit>> {
  @override
  LoadListState<Unit> build() {
    return LoadListState<Unit>.initial();
  }

  @override
  Future<LoadResult<Unit>> fetchData(LoadListQuery query) async {
    final repository = ref.read(unitRepositoryProvider);
    return repository.search(query.search ?? '', query.page, query.pageSize);
  }

  // Create a unit
  Future<Unit> createUnit(Unit unit) async {
    try {
      showLoading();
      final repository = ref.read(unitRepositoryProvider);
      final createdUnit = await repository.create(unit);

      final List<Unit> updatedData = [...state.data, createdUnit];
      state = state.copyWith(
        data: updatedData,
      );
      showSuccess(LKey.unitCreateSuccess.tr());
      return createdUnit;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      showError('${LKey.unitCreateError.tr()}: ${e.toString()}');
      rethrow;
    } finally {
      hideLoading();
    }
  }

  // Update a unit
  Future<void> updateUnit(Unit unit) async {
    try {
      showLoading();
      final repository = ref.read(unitRepositoryProvider);
      final updatedUnit = await repository.update(unit);

      final List<Unit> updatedData = state.data.map((u) => u.id == updatedUnit.id ? updatedUnit : u).toList();
      state = state.copyWith(
        data: updatedData,
      );
      showSuccess(LKey.unitUpdateSuccess.tr());
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      showError('${LKey.unitUpdateError.tr()}: ${e.toString()}');
      rethrow;
    } finally {
      hideLoading();
    }
  }

  // Delete a unit
  Future<bool> deleteUnit(Unit unit) async {
    try {
      showLoading();
      final repository = ref.read(unitRepositoryProvider);
      final success = await repository.delete(unit);

      if (success == true) {
        final List<Unit> updatedData = state.data.where((u) => u.id != unit.id).toList();
        state = state.copyWith(
          data: updatedData,
        );
        showSuccess(LKey.unitDeleteSuccess.tr());
        return true;
      } else {
        showError(LKey.unitDeleteError.tr());
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      showError('${LKey.unitDeleteError.tr()}: ${e.toString()}');
      return false;
    } finally {
      hideLoading();
    }
  }

  // Remove multiple units
  Future<void> removeMultipleUnits() async {
    try {
      showLoading();
      final units = ref.read(multiSelectUnitProvider).data.toList();

      if (units.isEmpty) {
        showError(LKey.unitNoSelection.tr());
        return;
      }

      final repository = ref.read(unitRepositoryProvider);
      for (final unit in units) {
        await repository.delete(unit);
      }

      state = state.copyWith(
        data: state.data.where((u) => !units.contains(u)).toList(),
      );

      showSuccess(LKey.unitDeleteSuccess.tr());
      ref.read(multiSelectUnitProvider.notifier).clear();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      showError('${LKey.unitDeleteError.tr()}: ${e.toString()}');
    } finally {
      hideLoading();
    }
  }

  // Get all units
  Future<List<Unit>> getAllUnits() async {
    try {
      final repository = ref.read(unitRepositoryProvider);
      return repository.getAll();
    } catch (e) {
      showError('${LKey.unitFetchError.tr()}: ${e.toString()}');
      return [];
    }
  }
}

// Simple provider to get all units
final allUnitsProvider = FutureProvider.autoDispose<List<Unit>>((ref) async {
  return ref.read(unitRepositoryProvider).getAll();
});

// Current unit provider for optimized cards
final currentUnitProvider = Provider<Unit>((ref) => throw UnimplementedError());

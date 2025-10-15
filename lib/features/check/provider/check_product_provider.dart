import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/index.dart';
import '../../../resources/index.dart';
import '../../../shared_widgets/toast.dart';

part 'check_product_provider.g.dart';

@riverpod
class CheckedList extends _$CheckedList {
  int get sessionId => arg.id;

  @override
  Future<List<CheckedProduct>> build(CheckSession arg) {
    final checkedProductRepo = ref.read(checkedProductRepositoryProvider);

    return checkedProductRepo.getCheckedListBySession(arg.id);
  }

  Future<void> addCheck({
    required Product product,
    required int checkQuantity,
    required List<CheckedInventoryLot> lots,
    String? note,
  }) async {
    final checkRepo = ref.read(checkRepositoryProvider);

    final checkedProduct = await checkRepo.addProductToSession(
      arg,
      product,
      checkQuantity,
      lots,
      note: note,
    );

    showSuccess(message: LKey.checkProductAddSuccess.tr());
    state = AsyncValue.data([
      checkedProduct,
      ...state.valueOrNull ?? [],
    ]);
  }

  Future<void> updateCheck({
    required CheckedProduct checkedProduct,
    required int checkQuantity,
    required List<CheckedInventoryLot> lots,
    String? note,
  }) async {
    final checkRepo = ref.read(checkRepositoryProvider);

    final updatedProduct = await checkRepo.updateInventoryCheck(
      checkedProduct.copyWith(
        actualQuantity: checkQuantity,
        note: note,
        lots: lots,
      ),
    );

    showSuccess(message: LKey.checkProductUpdateSuccess.tr());

    state = AsyncValue.data([
      ...state.valueOrNull!
          .map((e) => e.id == updatedProduct.id ? updatedProduct : e),
    ]);
  }

  CheckedProduct? checkExistProduct({
    required Product product,
  }) {
    return state.value?.firstWhereOrNull((e) => e.product.id == product.id);
  }
}

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/index.dart';
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
    String? note,
  }) async {
    final checkRepo = ref.read(checkRepositoryProvider);

    final checkedProduct = await checkRepo.addProductToSession(arg, product, checkQuantity, note: note);

    showSuccess(message: 'Thêm sản phẩm vào kiểm kê thành công');
    state = AsyncValue.data([
      checkedProduct,
      ...state.valueOrNull ?? [],
    ]);
  }

  Future<void> updateCheck({
    required CheckedProduct checkedProduct,
    required int checkQuantity,
    String? note,
  }) async {
    final checkRepo = ref.read(checkRepositoryProvider);

    final updatedProduct = await checkRepo.updateInventoryCheck(
      checkedProduct.copyWith(
        actualQuantity: checkQuantity,
        note: note,
      ),
    );

    showSuccess(message: 'Cập nhật kiểm kê thành công');

    state = AsyncValue.data([
      ...state.valueOrNull!.map((e) => e.id == updatedProduct.id ? updatedProduct : e),
    ]);
  }
}

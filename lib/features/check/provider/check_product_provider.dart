import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/index.dart';

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

    state = AsyncValue.data([
      checkedProduct,
      ...state.valueOrNull ?? [],
    ]);
  }
}

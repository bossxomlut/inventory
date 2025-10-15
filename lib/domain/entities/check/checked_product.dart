import 'package:freezed_annotation/freezed_annotation.dart';

import '../product/inventory.dart';
import 'check_session.dart';

part 'checked_product.freezed.dart';
part 'checked_product.g.dart';

// Model representing an item included in a stocktake session.
@freezed
class CheckedProduct with _$CheckedProduct {
  const factory CheckedProduct({
    required int id,
    required Product product,
    required CheckSession session,
    required int expectedQuantity,
    required int actualQuantity,
    required DateTime checkDate,
    String? note,
    @Default(<CheckedInventoryLot>[]) List<CheckedInventoryLot> lots,
  }) = _CheckedProduct;

  const CheckedProduct._();

  factory CheckedProduct.fromJson(Map<String, dynamic> json) =>
      _$CheckedProductFromJson(json);

  // Computed properties
  CheckStatus get status {
    if (actualQuantity == expectedQuantity) {
      return CheckStatus.match;
    } else if (actualQuantity > expectedQuantity) {
      return CheckStatus.surplus;
    } else {
      return CheckStatus.shortage;
    }
  }

  String get productName => product.name;
  int get difference => actualQuantity - expectedQuantity;
  bool get hasDiscrepancy => actualQuantity != expectedQuantity;
}

@freezed
class CheckedInventoryLot with _$CheckedInventoryLot {
  const factory CheckedInventoryLot({
    required int id,
    int? inventoryLotId,
    required DateTime expiryDate,
    DateTime? manufactureDate,
    required int expectedQuantity,
    required int actualQuantity,
  }) = _CheckedInventoryLot;

  factory CheckedInventoryLot.fromJson(Map<String, dynamic> json) =>
      _$CheckedInventoryLotFromJson(json);
}

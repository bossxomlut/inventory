import 'package:freezed_annotation/freezed_annotation.dart';

import '../product/inventory.dart';
import 'check_session.dart';

part 'checked_product.freezed.dart';
part 'checked_product.g.dart';

// Model cho sản phẩm đã kiểm kê
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
  }) = _CheckedProduct;

  const CheckedProduct._();

  factory CheckedProduct.fromJson(Map<String, dynamic> json) => _$CheckedProductFromJson(json);

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

  // Helper methods for UI display
  String get statusText {
    switch (status) {
      case CheckStatus.match:
        return 'Khớp';
      case CheckStatus.surplus:
        return 'Thừa';
      case CheckStatus.shortage:
        return 'Thiếu';
      default:
        return 'Không xác định';
    }
  }

  String get differenceText {
    if (difference == 0) return 'Khớp';
    if (difference > 0) return '+$difference';
    return '$difference';
  }
}

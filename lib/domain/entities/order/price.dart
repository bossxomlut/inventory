import '../index.dart';

part 'price.freezed.dart';

@freezed
class ProductPrice with _$ProductPrice {
  const factory ProductPrice({
    required int id,
    required int productId,
    required String productName,
    double? purchasePrice, // Giá mua
    double? sellingPrice,
  }) = _ProductPrice;
}

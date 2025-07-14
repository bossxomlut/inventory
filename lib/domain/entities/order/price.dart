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

  const ProductPrice._();
}

extension ProductPriceX on ProductPrice {
// Calculate profit percentage
  double? get profitPercentage {
    if (sellingPrice != null && purchasePrice != null && purchasePrice! > 0) {
      return ((sellingPrice! - purchasePrice!) / purchasePrice!) * 100;
    }
    return null;
  }
}

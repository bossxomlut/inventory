import 'package:isar_community/isar.dart';

part 'product_price.g.dart';

@collection
class ProductPriceCollection {
  Id id = Isar.autoIncrement;
  late int productId;
  late String productName;
  double? purchasePrice; // Purchase price
  double? sellingPrice;
}

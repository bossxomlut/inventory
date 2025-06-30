import 'package:isar/isar.dart';
import 'package:sample_app/data/order/product_price.dart';

import '../../domain/entities/order/price.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../database/isar_repository.dart';

class PriceRepositoryImpl extends PriceRepository with IsarCrudRepository<ProductPrice, ProductPriceCollection> {
  @override
  ProductPriceCollection createNewItem(ProductPrice item) {
    return ProductPriceCollection()
      ..productId = item.productId
      ..productName = item.productName
      ..purchasePrice = item.purchasePrice
      ..sellingPrice = item.sellingPrice;
  }

  @override
  int? getId(ProductPrice item) {
    return item.id;
  }

  @override
  Future<ProductPrice> getItemFromCollection(ProductPriceCollection collection) {
    return Future.value(
      ProductPrice(
        id: collection.id,
        productId: collection.productId,
        purchasePrice: collection.purchasePrice,
        sellingPrice: collection.sellingPrice,
        productName: collection.productName,
      ),
    );
  }

  @override
  ProductPriceCollection updateNewItem(ProductPrice item) {
    return ProductPriceCollection()
      ..id = item.id
      ..productId = item.productId
      ..productName = item.productName
      ..purchasePrice = item.purchasePrice
      ..sellingPrice = item.sellingPrice;
  }

  @override
  Future<ProductPrice> getProductPriceByProductId(int productId) {
    return iCollection.filter().productIdEqualTo(productId).findFirst().then((collection) {
      if (collection == null) {
        throw Exception('Product price not found for productId: $productId');
      }
      return getItemFromCollection(collection);
    });
  }
}

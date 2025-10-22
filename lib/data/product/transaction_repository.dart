import 'package:isar_community/isar.dart';

import '../../domain/entities/index.dart';
import '../../domain/repositories/product/transaction_repository.dart';
import '../database/isar_repository.dart';
import 'inventory.dart';

class TransactionRepositoryImpl extends TransactionRepository
    with IsarCrudRepository<Transaction, TransactionCollection> {
  @override
  TransactionCollection createNewItem(Transaction item) {
    return TransactionCollection()
      ..quantity = item.quantity
      ..productId = item.productId
      ..inventoryLotId = item.inventoryLotId
      ..type = item.type
      ..category = item.category
      ..timestamp = item.timestamp;
  }

  @override
  int? getId(Transaction item) {
    return item.id;
  }

  @override
  Future<Transaction> getItemFromCollection(TransactionCollection collection) {
    return Future.value(
      Transaction(
        id: collection.id,
        productId: collection.productId,
        quantity: collection.quantity,
        type: collection.type,
        category: collection.category,
        timestamp: collection.timestamp,
        inventoryLotId: collection.inventoryLotId,
      ),
    );
  }

  @override
  TransactionCollection updateNewItem(Transaction item) {
    return TransactionCollection()
      ..id = item.id
      ..productId = item.productId
      ..inventoryLotId = item.inventoryLotId
      ..quantity = item.quantity
      ..type = item.type
      ..category = item.category
      ..timestamp = item.timestamp;
  }

  @override
  Future<List<Transaction>> getTransactionsByProductId(int productId) {
    return iCollection
        .filter()
        .productIdEqualTo(productId)
        .sortByTimestampDesc()
        .findAll()
        .then(
          (collections) => collections.map(
            (TransactionCollection e) {
              return Transaction(
                id: e.id,
                productId: e.productId,
                quantity: e.quantity,
                type: e.type,
                category: e.category,
                timestamp: e.timestamp,
                inventoryLotId: e.inventoryLotId,
              );
            },
          ).toList(),
        );
  }
}

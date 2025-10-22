import 'package:isar_community/isar.dart';

import '../../domain/entities/get_id.dart';
import '../../domain/entities/product/inventory.dart';
import '../../domain/exceptions/crud_exceptions.dart';
import '../../domain/repositories/product/inventory_lot_repository.dart';
import '../database/isar_repository.dart';
import 'inventory.dart';
import 'inventory_mapping.dart';

class InventoryLotRepositoryImpl extends InventoryLotRepository
    with IsarCrudRepository<InventoryLot, InventoryLotCollection> {
  IsarCollection<ProductCollection> get _productCollection =>
      isar.collection<ProductCollection>();

  InventoryLotCollection _createCollection(InventoryLot item) {
    return InventoryLotCollection()
      ..id = item.id == undefinedId ? Isar.autoIncrement : item.id
      ..productId = item.productId
      ..quantity = item.quantity
      ..expiryDate = item.expiryDate
      ..manufactureDate = item.manufactureDate
      ..createdAt = item.createdAt ?? DateTime.now()
      ..updatedAt = item.updatedAt ?? DateTime.now();
  }

  @override
  InventoryLotCollection createNewItem(InventoryLot item) {
    return _createCollection(item);
  }

  @override
  InventoryLotCollection updateNewItem(InventoryLot item) {
    return _createCollection(item)..updatedAt = DateTime.now();
  }

  @override
  Future<InventoryLot> getItemFromCollection(
      InventoryLotCollection collection) async {
    return InventoryLotMapping().from(collection);
  }

  @override
  int? getId(InventoryLot item) => item.id == undefinedId ? null : item.id;

  Future<void> _attachProductLink(InventoryLotCollection lot) async {
    final product = await _productCollection.get(lot.productId);
    if (product == null) {
      throw NotFoundException(
          'No product found with id ${lot.productId}.');
    }
    lot.product.value = product;
    await lot.product.save();
  }

  @override
  Future<InventoryLot> create(InventoryLot item) async {
    final lot = createNewItem(item);
    try {
      final id = await isar.writeTxn(() async {
        final lotId = await iCollection.put(lot);
        await _attachProductLink(lot);
        return lotId;
      });
      return read(id);
    } on IsarError catch (error) {
      rethrowDuplicateLotError(error);
    }
  }

  @override
  Future<InventoryLot> update(InventoryLot item) async {
    if (item.id == undefinedId) {
      throw ValidationException(
          'Cannot update an inventory lot before it has an identifier.');
    }

    final lot = updateNewItem(item)
      ..createdAt = item.createdAt ?? DateTime.now();

    try {
      await isar.writeTxn(() async {
        await iCollection.put(lot);
        await _attachProductLink(lot);
      });
      return read(lot.id);
    } on IsarError catch (error) {
      rethrowDuplicateLotError(error);
    }
  }

  @override
  Future<List<InventoryLot>> getLotsByProduct(int productId) async {
    final lots = await iCollection
        .filter()
        .productIdEqualTo(productId)
        .sortByExpiryDate()
        .findAll();
    return lots.map(InventoryLotMapping().from).toList();
  }

  @override
  Future<void> deleteLotsByIds(Iterable<int> ids) async {
    if (ids.isEmpty) {
      return;
    }

    await isar.writeTxn(() async {
      await iCollection.deleteAll(ids.toList());
    });
  }

  @override
  Future<R> runInTransaction<R>(Future<R> Function() action) {
    return isar.writeTxn(action);
  }

  @override
  Never rethrowDuplicateLotError(Object error) {
    if (error is IsarError &&
        error.message.contains('Unique index violation')) {
      throw DuplicateEntryException(
          'A lot with the same expiry and manufacture date already exists for this product.');
    }
    throw error;
  }
}

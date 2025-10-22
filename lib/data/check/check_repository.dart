import 'package:isar_community/isar.dart';

import '../../domain/index.dart';
import '../../domain/repositories/index.dart';
import '../../domain/repositories/product/update_product_repository.dart';
import '../../provider/load_list.dart';
import '../database/isar_repository.dart';
import '../product/inventory_mapping.dart';
import 'check_collection.dart';
import 'check_mapping.dart';

class CheckRepositoryImpl extends CheckRepository {
  final CheckSessionRepository checkSessionRepository;
  final CheckedProductRepository checkedProductRepository;
  final UpdateProductRepository updateProductRepository;

  CheckRepositoryImpl({
    required this.checkSessionRepository,
    required this.checkedProductRepository,
    required this.updateProductRepository,
  });

  @override
  Future<CheckedProduct> addProductToSession(
    CheckSession session,
    Product product,
    int actualQuantity,
    List<CheckedInventoryLot> lots, {
    String? note,
  }) {
    final computedQuantity = lots.isNotEmpty
        ? lots.fold<int>(0, (sum, lot) => sum + lot.actualQuantity)
        : actualQuantity;

    return checkedProductRepository.create(
      CheckedProduct(
        id: undefinedId,
        product: product,
        expectedQuantity: product.quantity,
        session: session,
        actualQuantity: computedQuantity,
        note: note,
        checkDate: DateTime.now(),
        lots: lots,
      ),
    );
  }

  @override
  Future<CheckSession> createSession(String name, String createdBy,
      {String? note, String? checkedBy}) {
    return checkSessionRepository.create(
      CheckSession(
        id: undefinedId,
        name: name,
        createdBy: createdBy,
        status: CheckSessionStatus.inProgress,
        startDate: DateTime.now(),
        endDate: null,
        note: note,
        checks: [],
      ),
    );
  }

  @override
  Future<CheckSession> updateSession(CheckSession session) async {
    //get all checkedProduct of this session

    final checkedProducts =
        await checkedProductRepository.getCheckedListBySession(session.id);
    // Update the session with the current checks

    //update product quantity in session
    //add to transaction

    for (var check in checkedProducts) {
      final updatedProduct = check.product.copyWith(
        quantity: check.actualQuantity,
        enableExpiryTracking: check.product.enableExpiryTracking,
        lots: check.product.enableExpiryTracking
            ? check.lots
                .where((lot) => lot.actualQuantity > 0)
                .map(
                  (lot) => InventoryLot(
                    id: lot.inventoryLotId ?? undefinedId,
                    productId: check.product.id,
                    quantity: lot.actualQuantity,
                    expiryDate: lot.expiryDate,
                    manufactureDate: lot.manufactureDate,
                  ),
                )
                .toList()
            : const [],
      );

      await updateProductRepository.updateProduct(
        updatedProduct,
        TransactionCategory.check,
      );
    }

    return checkSessionRepository.update(session);
  }

  @override
  Future<List<CheckSession>> getActiveSessions() {
    return checkSessionRepository.getActiveSessions();
  }

  @override
  Future<List<CheckSession>> getDoneSessions() {
    return checkSessionRepository.getDoneSessions();
  }

  @override
  Future<List<CheckedProduct>> getChecksBySession(int sessionId) {
    return checkedProductRepository.getCheckedListBySession(sessionId);
  }

  @override
  Future<CheckedProduct> updateInventoryCheck(CheckedProduct check) {
    final computedQuantity = check.lots.isNotEmpty
        ? check.lots.fold<int>(0, (sum, lot) => sum + lot.actualQuantity)
        : check.actualQuantity;

    return checkedProductRepository.update(
      check.copyWith(actualQuantity: computedQuantity),
    );
  }

  @override
  Future<void> deleteInventoryCheck(CheckedProduct check) {
    return checkedProductRepository.delete(check);
  }

  @override
  Future<void> deleteSession(CheckSession session) {
    return checkSessionRepository.delete(session);
  }
}

class CheckSessionRepositoryImpl extends CheckSessionRepository
    with IsarCrudRepository<CheckSession, CheckSessionCollection> {
  @override
  int? getId(CheckSession item) => item.id;

  @override
  Future<CheckSession> getItemFromCollection(
      CheckSessionCollection collection) async {
    return CheckSession(
      id: collection.id,
      name: collection.name,
      createdBy: collection.createdBy,
      status: collection.status,
      startDate: collection.startDate,
      endDate: collection.endDate,
      note: collection.note,
      checks: [],
    );
  }

  @override
  CheckSessionCollection createNewItem(CheckSession item) {
    final collection = CheckSessionCollection()
      ..name = item.name
      ..createdBy = item.createdBy
      ..status = item.status
      ..startDate = item.startDate
      ..endDate = item.endDate
      ..note = item.note;

    return collection;
  }

  @override
  CheckSessionCollection updateNewItem(CheckSession item) {
    return CheckSessionCollection()
      ..id = item.id
      ..name = item.name
      ..createdBy = item.createdBy
      ..status = item.status
      ..startDate = item.startDate
      ..endDate = item.endDate
      ..note = item.note;
  }

  @override
  Future<List<CheckSession>> getActiveSessions() {
    return isar.txnSync(() async {
      final collections = isar.checkSessionCollections
          .filter()
          .statusEqualTo(CheckSessionStatus.inProgress)
          .findAllSync();

      return Future.wait(collections.map(getItemFromCollection));
    });
  }

  @override
  Future<List<CheckSession>> getDoneSessions() {
    return isar.txnSync(() async {
      final collections = isar.checkSessionCollections
          .filter()
          .statusEqualTo(CheckSessionStatus.completed)
          .findAllSync();

      return Future.wait(collections.map(getItemFromCollection));
    });
  }
}

class CheckedProductRepositoryImpl extends CheckedProductRepository
    with IsarCrudRepository<CheckedProduct, CheckedProductCollection> {
  IsarCollection<CheckedInventoryLotCollection> get _lotCollection =>
      isar.collection<CheckedInventoryLotCollection>();

  @override
  int? getId(CheckedProduct item) => item.id;

  @override
  Future<CheckedProduct> getItemFromCollection(
      CheckedProductCollection collection) async {
    await collection.product.load();
    await collection.session.load();
    if (collection.product.value != null) {
      await collection.product.value!.images.load();
      await collection.product.value!.lots.load();
    }
    await collection.lots.load();

    final lots = collection.lots
        .map((lot) => CheckedInventoryLotCollectionMapping().from(lot))
        .toList();

    return CheckedProduct(
      id: collection.id,
      product: ProductMapping().from(collection.product.value!),
      session: SessionMapping().from(collection.session.value!),
      expectedQuantity: collection.expectedQuantity,
      actualQuantity: collection.actualQuantity,
      checkDate: collection.checkDate,
      note: collection.note,
      lots: lots,
    );
  }

  @override
  CheckedProductCollection createNewItem(CheckedProduct item) {
    return CheckedProductCollection()
      ..product.value = ProductCollectionMapping().from(item.product)
      ..session.value = SessionCollectionMapping().from(item.session)
      ..expectedQuantity = item.expectedQuantity
      ..actualQuantity = item.actualQuantity
      ..checkDate = item.checkDate
      ..note = item.note;
  }

  @override
  CheckedProductCollection updateNewItem(CheckedProduct item) {
    return CheckedProductCollection()
      ..id = item.id // Assuming id is set for update
      ..product.value = ProductCollectionMapping().from(item.product)
      ..session.value = SessionCollectionMapping().from(item.session)
      ..expectedQuantity = item.expectedQuantity
      ..actualQuantity = item.actualQuantity
      ..checkDate = item.checkDate
      ..note = item.note;
  }

  @override
  Future<CheckedProduct> create(CheckedProduct item) async {
    final collection = createNewItem(item);
    final lotCollections =
        item.lots.map((lot) => CheckedInventoryLotMapping().from(lot)).toList();

    await isar.writeTxn(() async {
      await iCollection.put(collection);
      await collection.product.save();
      await collection.session.save();

      for (final lotCollection in lotCollections) {
        lotCollection.checkedProduct.value = collection;
        await _lotCollection.put(lotCollection);
        await lotCollection.checkedProduct.save();
      }
    });

    return read(collection.id);
  }

  @override
  Future<CheckedProduct> update(CheckedProduct item) async {
    final existing = await iCollection.get(item.id);
    if (existing == null) {
      throw NotFoundException('Checked product not found');
    }

    final lotCollections =
        item.lots.map((lot) => CheckedInventoryLotMapping().from(lot)).toList();

    await isar.writeTxn(() async {
      existing
        ..expectedQuantity = item.expectedQuantity
        ..actualQuantity = item.actualQuantity
        ..checkDate = item.checkDate
        ..note = item.note;
      existing.product.value = ProductCollectionMapping().from(item.product);
      existing.session.value = SessionCollectionMapping().from(item.session);

      await iCollection.put(existing);
      await existing.product.save();
      await existing.session.save();

      await existing.lots.load();
      final oldIds = existing.lots.map((lot) => lot.id).toList();
      if (oldIds.isNotEmpty) {
        await _lotCollection.deleteAll(oldIds);
      }

      for (final lotCollection in lotCollections) {
        lotCollection.checkedProduct.value = existing;
        await _lotCollection.put(lotCollection);
        await lotCollection.checkedProduct.save();
      }
    });

    return read(item.id);
  }

  @override
  Future<LoadResult<CheckedProduct>> search(String keyword, int page, int limit,
      {Map<String, dynamic>? filter}) async {
    return isar.txn(() async {
      // Get all collections first
      var collections = await iCollection.where().findAll();

      // Apply keyword search if needed (e.g., by product name or checked by)
      if (keyword.isNotEmpty) {
        collections = collections
            .where((c) =>
                c.product.value?.name
                    .toLowerCase()
                    .contains(keyword.toLowerCase()) ??
                false)
            .toList();
      }

      // Apply date range filter if provided
      if (filter != null &&
          filter.containsKey('startDate') &&
          filter.containsKey('endDate')) {
        final startDate = filter['startDate'] as DateTime;
        final endDate = filter['endDate'] as DateTime;
        collections = collections
            .where((c) =>
                c.checkDate.isAfter(startDate) && c.checkDate.isBefore(endDate))
            .toList();
      }

      // Apply sorting
      if (filter != null && filter.containsKey('sortType')) {
        final sortType = filter['sortType'] as String;
        switch (sortType) {
          case 'dateAsc':
            collections.sort((a, b) => a.checkDate.compareTo(b.checkDate));
            break;
          case 'dateDesc':
            collections.sort((a, b) => b.checkDate.compareTo(a.checkDate));
            break;
          default:
            collections.sort((a, b) => b.checkDate.compareTo(a.checkDate));
        }
      } else {
        // Default sort by check date descending (newest first)
        collections.sort((a, b) => b.checkDate.compareTo(a.checkDate));
      }

      // Apply pagination
      final startIndex = (page - 1) * limit;
      if (startIndex >= collections.length) {
        return LoadResult<CheckedProduct>(
          data: [],
          totalCount: collections.length,
        );
      }

      final endIndex = startIndex + limit > collections.length
          ? collections.length
          : startIndex + limit;
      final paginatedCollections = collections.sublist(startIndex, endIndex);

      // Convert to domain entities
      return LoadResult<CheckedProduct>(
        data:
            await Future.wait(paginatedCollections.map(getItemFromCollection)),
        totalCount: collections.length,
      );
    });
  }

  @override
  Future<List<CheckedProduct>> getCheckedListBySession(int sessionId) async {
    final collections = await isar.checkedProductCollections
        .filter()
        .session((q) => q.idEqualTo(sessionId))
        .findAll();

    return Future.wait(collections.map(getItemFromCollection));
  }

  @override
  Future<List<CheckedProduct>> getAll() async {
    final collections = await isar.checkedProductCollections.where().findAll();
    return Future.wait(collections.map(getItemFromCollection));
  }
}

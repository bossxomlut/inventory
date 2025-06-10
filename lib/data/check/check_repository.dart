import 'package:isar/isar.dart';

import '../../domain/entities/check/check.dart';
import '../../domain/index.dart';
import '../../domain/repositories/index.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../database/isar_repository.dart';
import '../product/inventory_mapping.dart';
import 'check_collection.dart';

class CheckRepositoryImpl extends CheckRepository {
  final CheckSessionRepository checkSessionRepository;
  final CheckedProductRepository checkedProductRepository;
  final SearchProductRepository searchProductRepository;

  CheckRepositoryImpl({
    required this.checkSessionRepository,
    required this.checkedProductRepository,
    required this.searchProductRepository,
  });

  @override
  Future<CheckedProduct> addProductToSession(int sessionId, Product product, int actualQuantity, String checkedBy, {String? note}) {
    return checkedProductRepository.create(
      CheckedProduct(
        id: undefinedId,
        product: product,
        expectedQuantity: product.quantity,
        actualQuantity: actualQuantity,
        checkDate: DateTime.now(),
        checkedBy: checkedBy,
      ),
    );
  }

  @override
  Future<CheckSession> createSession(String name, String createdBy, {String? note}) {
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
  Future<CheckSession> updateSession(CheckSession session) {
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
  Future<Product?> findProductByBarcode(String barcode) async {
    try {
      final product = await searchProductRepository.searchByBarcode(barcode);
      return product;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Product>> searchProducts(String keyword, {int page = 1, int pageSize = 20}) {
    return searchProductRepository.search(keyword, page, pageSize);
  }

  @override
  Future<List<CheckedProduct>> getChecksBySession(int sessionId) {
    return checkedProductRepository.getChecksBySession(sessionId);
  }

  @override
  Future<CheckedProduct> updateInventoryCheck(CheckedProduct check) {
    return checkedProductRepository.update(check);
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

class CheckSessionRepositoryImpl extends CheckSessionRepository with IsarCrudRepository<CheckSession, CheckSessionCollection> {
  @override
  int? getId(CheckSession item) => item.id;

  @override
  Future<CheckSession> getItemFromCollection(CheckSessionCollection collection) async {
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
      final collections = isar.checkSessionCollections.filter().statusEqualTo(CheckSessionStatus.draft).or().statusEqualTo(CheckSessionStatus.inProgress).findAllSync();

      return Future.wait(collections.map(getItemFromCollection));
    });
  }

  @override
  Future<List<CheckSession>> getDoneSessions() {
    return isar.txnSync(() async {
      final collections = isar.checkSessionCollections.filter().statusEqualTo(CheckSessionStatus.cancelled).or().statusEqualTo(CheckSessionStatus.completed).findAllSync();

      return Future.wait(collections.map(getItemFromCollection));
    });
  }
}

class CheckedProductRepositoryImpl extends CheckedProductRepository with IsarCrudRepository<CheckedProduct, CheckedProductCollection> {
  @override
  int? getId(CheckedProduct item) => item.id;

  @override
  Future<CheckedProduct> getItemFromCollection(CheckedProductCollection collection) async {
    return CheckedProduct(
      id: collection.id,
      product: ProductMapping().from(collection.product.value!),
      expectedQuantity: collection.expectedQuantity,
      actualQuantity: collection.actualQuantity,
      checkDate: collection.checkDate,
      checkedBy: collection.checkedBy,
      note: collection.note,
    );
  }

  @override
  CheckedProductCollection createNewItem(CheckedProduct item) {
    return CheckedProductCollection()
      ..product.value = ProductCollectionMapping().from(item.product)
      ..expectedQuantity = item.expectedQuantity
      ..actualQuantity = item.actualQuantity
      ..checkDate = item.checkDate
      ..checkedBy = item.checkedBy
      ..note = item.note;
  }

  @override
  CheckedProductCollection updateNewItem(CheckedProduct item) {
    return CheckedProductCollection()
      ..id = item.id // Assuming id is set for update
      ..product.value = ProductCollectionMapping().from(item.product)
      ..expectedQuantity = item.expectedQuantity
      ..actualQuantity = item.actualQuantity
      ..checkDate = item.checkDate
      ..checkedBy = item.checkedBy
      ..note = item.note;
  }

  @override
  Future<List<CheckedProduct>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter}) async {
    return isar.txn(() async {
      // Get all collections first
      var collections = await iCollection.where().findAll();
      
      // Apply keyword search if needed (e.g., by product name or checked by)
      if (keyword.isNotEmpty) {
        collections = collections.where((c) => 
          c.product.value?.name.toLowerCase().contains(keyword.toLowerCase()) == true || 
          c.checkedBy.toLowerCase().contains(keyword.toLowerCase())
        ).toList();
      }
      
      // Apply date range filter if provided
      if (filter != null && filter.containsKey('startDate') && filter.containsKey('endDate')) {
        final startDate = filter['startDate'] as DateTime;
        final endDate = filter['endDate'] as DateTime;
        collections = collections.where((c) => 
          c.checkDate.isAfter(startDate) && c.checkDate.isBefore(endDate)
        ).toList();
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
        return <CheckedProduct>[];
      }
      
      final endIndex = startIndex + limit > collections.length ? 
        collections.length : startIndex + limit;
      final paginatedCollections = collections.sublist(startIndex, endIndex);
      
      // Convert to domain entities
      return Future.wait(paginatedCollections.map(getItemFromCollection));
    });
  }

  @override
  Future<List<CheckedProduct>> getChecksBySession(int sessionId) {
    return isar.txnSync(() async {
      // Using Sync API as in original code
      final collections = isar.checkedProductCollections
          .filter()
          .session(
            (q) => q.idEqualTo(sessionId),
          )
          .findAllSync();

      return Future.wait(collections.map(getItemFromCollection));
    });
  }
}

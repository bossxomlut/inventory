import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/product/inventory_lot_repository.dart';
import '../../entities/product/inventory.dart';
import '../../exceptions/crud_exceptions.dart';
import '../crud_repository.dart';

part 'inventory_lot_repository.g.dart';

@riverpod
InventoryLotRepository inventoryLotRepository(ref) =>
    InventoryLotRepositoryImpl();

abstract class InventoryLotRepository
    implements CrudRepository<InventoryLot, int> {
  Future<List<InventoryLot>> getLotsByProduct(int productId);

  Future<void> deleteLotsByIds(Iterable<int> ids);

  Future<R> runInTransaction<R>(Future<R> Function() action);

  Never rethrowDuplicateLotError(Object error) {
    throw DuplicateEntryException(
        'Lô sản phẩm với ngày hết hạn và ngày sản xuất này đã tồn tại.');
  }
}

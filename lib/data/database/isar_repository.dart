import 'package:isar_community/isar.dart';

import '../../domain/index.dart';
import '../../domain/repositories/index.dart';

mixin IsarCrudRepository<T, C> on CrudRepository<T, Id> {
  final Isar _isar = Isar.getInstance()!;

  Isar get isar => _isar;

  IsarCollection<C> get iCollection => isar.collection<C>();

  C createNewItem(T item);

  C updateNewItem(T item);

  Future<T> getItemFromCollection(C collection);

  int? getId(T item);

  @override
  Future<T> create(T item) {
    final C nItem = createNewItem(item);

    final id = isar.writeTxnSync(() => iCollection.putSync(nItem));
    return read(id);
  }

  @override
  Future<bool> delete(T item) {
    final int? id = getId(item);
    if (id == null) {
      throw NotFoundException('Item not found');
    }

    return isar.writeTxn(() async {
      return iCollection.delete(id);
    });
  }

  @override
  Future<T> read(int id) {
    return iCollection.get(id).then((collection) {
      if (collection == null) {
        throw NotFoundException('Item not found');
      }

      return getItemFromCollection(collection);
    });
  }

  @override
  Future<T> update(T item) {
    final int? id = getId(item);

    if (id == null) {
      throw UnimplementedError();
    }

    final nItem = updateNewItem(item);
    return isar.writeTxn(() async {
      return iCollection.put(nItem).then((id) => getItemFromCollection(nItem));
    });
  }
}

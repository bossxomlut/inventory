import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/unit/unit.dart';
import '../../domain/repositories/unit/unit_repository.dart';
import '../isar/schema/unit_collection.dart';
import '../../provider/load_list.dart';

final unitRepositoryProvider = Provider<UnitRepository>((ref) => UnitRepositoryImpl());

class UnitRepositoryImpl implements UnitRepository {
  final Isar _isar = Isar.getInstance()!;

  IsarCollection<UnitCollection> get iCollection => _isar.collection<UnitCollection>();

  @override
  Future<Unit> create(Unit unit) async {
    final now = DateTime.now();
    final unitWithDates = unit.copyWith(createDate: now, updatedDate: now);

    final collection = UnitCollection()
      ..name = unitWithDates.name
      ..description = unitWithDates.description
      ..createDate = unitWithDates.createDate
      ..updatedDate = unitWithDates.updatedDate;

    final id = await _isar.writeTxn(() => iCollection.put(collection));
    return unitWithDates.copyWith(id: id);
  }

  @override
  Future<bool> delete(Unit unit) async {
    return await _isar.writeTxn(() => iCollection.delete(unit.id));
  }

  @override
  Future<Unit> read(int id) async {
    final collection = await iCollection.get(id);
    if (collection == null) {
      throw Exception('Unit not found');
    }

    return Unit(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      createDate: collection.createDate,
      updatedDate: collection.updatedDate,
    );
  }

  @override
  Future<Unit> update(Unit unit) async {
    final unitWithDate = unit.copyWith(updatedDate: DateTime.now());

    final collection = UnitCollection()
      ..id = unitWithDate.id
      ..name = unitWithDate.name
      ..description = unitWithDate.description
      ..createDate = unitWithDate.createDate
      ..updatedDate = unitWithDate.updatedDate;

    await _isar.writeTxn(() => iCollection.put(collection));
    return unitWithDate;
  }

  @override
  Future<List<Unit>> getAll() async {
    final collections = await iCollection.where().findAll();
    return collections
        .map((collection) => Unit(
              id: collection.id,
              name: collection.name,
              description: collection.description,
              createDate: collection.createDate,
              updatedDate: collection.updatedDate,
            ))
        .toList();
  }

  @override
  Future<Unit> getById(int id) async {
    final collection = await iCollection.get(id);
    if (collection == null) {
      throw Exception('Unit not found');
    }

    return Unit(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      createDate: collection.createDate,
      updatedDate: collection.updatedDate,
    );
  }

  @override
  Future<LoadResult<Unit>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter}) async {
    final allCollections = await iCollection.where().findAll();

    final filteredCollections = keyword.isEmpty ? allCollections : allCollections.where((c) => c.name.toLowerCase().contains(keyword.toLowerCase()) || (c.description?.toLowerCase().contains(keyword.toLowerCase()) ?? false)).toList();

    // Sort by name
    filteredCollections.sort((a, b) => a.name.compareTo(b.name));

    // Implement simple pagination in memory
    final start = (page - 1) * limit;
    final end = start + limit < filteredCollections.length ? start + limit : filteredCollections.length;

    final List<UnitCollection> paginatedCollections = start < filteredCollections.length ? filteredCollections.sublist(start, end) : <UnitCollection>[];

    final units = paginatedCollections
        .map((collection) => Unit(
              id: collection.id as int,
              name: collection.name as String,
              description: collection.description as String?,
              createDate: collection.createDate,
              updatedDate: collection.updatedDate,
            ))
        .toList();

    return LoadResult<Unit>(
      data: units,
      totalCount: filteredCollections.length,
    );
  }
}

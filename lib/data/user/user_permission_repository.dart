import 'package:isar/isar.dart';

import '../../domain/entities/permission/permission.dart';
import '../../domain/entities/permission/user_permission.dart';
import '../../domain/repositories/user/user_permission_repository.dart';
import 'user_permission.dart';

class UserPermissionRepositoryImpl implements UserPermissionRepository {
  UserPermissionRepositoryImpl() : _isar = Isar.getInstance()!;

  final Isar _isar;

  IsarCollection<UserPermissionCollection> get _collection =>
      _isar.userPermissionCollections;

  @override
  Future<List<UserPermission>> getPermissionsByUser(int userId) async {
    final results = await _collection.filter().userIdEqualTo(userId).findAll();
    return results
        .map(
          (entity) => UserPermission(
            id: entity.id,
            userId: entity.userId,
            key: PermissionKey.values
                .firstWhere((element) => element.name == entity.permissionKey),
            isEnabled: entity.isEnabled,
          ),
        )
        .toList();
  }

  @override
  Future<void> upsertPermission({
    required int userId,
    required PermissionKey key,
    required bool isEnabled,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _collection
          .filter()
          .userIdEqualTo(userId)
          .and()
          .permissionKeyEqualTo(key.name)
          .findFirst();
      if (existing != null) {
        existing.isEnabled = isEnabled;
        await _collection.put(existing);
      } else {
        final entity = UserPermissionCollection()
          ..userId = userId
          ..permissionKey = key.name
          ..isEnabled = isEnabled;
        await _collection.put(entity);
      }
    });
  }

  @override
  Future<void> deletePermission({
    required int userId,
    required PermissionKey key,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _collection
          .filter()
          .userIdEqualTo(userId)
          .and()
          .permissionKeyEqualTo(key.name)
          .findFirst();
      if (existing != null) {
        await _collection.delete(existing.id);
      }
    });
  }

  @override
  Future<void> deleteAllForUser(int userId) async {
    await _isar.writeTxn(() async {
      final ids = await _collection
          .filter()
          .userIdEqualTo(userId)
          .idProperty()
          .findAll();
      if (ids.isNotEmpty) {
        await _collection.deleteAll(ids);
      }
    });
  }
}

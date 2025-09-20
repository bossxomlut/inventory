import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/user/user_permission_repository.dart';
import '../../entities/permission/permission.dart';
import '../../entities/permission/user_permission.dart';

part 'user_permission_repository.g.dart';

@riverpod
UserPermissionRepository userPermissionRepository(
        UserPermissionRepositoryRef ref) =>
    UserPermissionRepositoryImpl();

abstract class UserPermissionRepository {
  Future<List<UserPermission>> getPermissionsByUser(int userId);

  Future<void> upsertPermission({
    required int userId,
    required PermissionKey key,
    required bool isEnabled,
  });

  Future<void> deletePermission({
    required int userId,
    required PermissionKey key,
  });

  Future<void> deleteAllForUser(int userId);
}

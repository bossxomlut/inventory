import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/permission/permission.dart';
import '../../../domain/repositories/user/user_permission_repository.dart';
import '../../../domain/entities/user/user.dart';

part 'user_permission_controller.g.dart';

@riverpod
class UserPermissionController extends _$UserPermissionController {
  @override
  FutureOr<Set<PermissionKey>> build(int userId) async {
    final defaults =
        PermissionCatalog.defaultPermissionsForUserRole(UserRole.user);
    final repo = ref.read(userPermissionRepositoryProvider);
    final stored = await repo.getPermissionsByUser(userId);
    if (stored.isEmpty) {
      return defaults;
    }

    final effective = {...defaults};
    for (final permission in stored) {
      if (permission.isEnabled) {
        effective.add(permission.key);
      } else {
        effective.remove(permission.key);
      }
    }
    return effective;
  }

  Future<void> togglePermission(PermissionKey key, bool enabled) async {
    final defaults =
        PermissionCatalog.defaultPermissionsForUserRole(UserRole.user);
    final defaultEnabled = defaults.contains(key);
    final repo = ref.read(userPermissionRepositoryProvider);

    if (enabled == defaultEnabled) {
      await repo.deletePermission(userId: userId, key: key);
    } else {
      await repo.upsertPermission(userId: userId, key: key, isEnabled: enabled);
    }

    final current = state.valueOrNull ?? await future;
    final updated = {...current};
    if (enabled) {
      updated.add(key);
    } else {
      updated.remove(key);
    }

    state = AsyncData(updated);
  }

  Future<void> resetToDefault() async {
    final repo = ref.read(userPermissionRepositoryProvider);
    await repo.deleteAllForUser(userId);
    final defaults =
        PermissionCatalog.defaultPermissionsForUserRole(UserRole.user);
    state = AsyncData(defaults);
  }
}

@riverpod
Future<Set<PermissionKey>> userEffectivePermissions(
    UserEffectivePermissionsRef ref, User user) async {
  if (user.role == UserRole.admin || user.role == UserRole.guest) {
    return PermissionCatalog.defaultPermissionsForUserRole(user.role);
  }
  final controller = ref.watch(userPermissionControllerProvider(user.id));
  if (controller.hasValue) {
    return controller.value!;
  }
  return ref.watch(userPermissionControllerProvider(user.id).future);
}

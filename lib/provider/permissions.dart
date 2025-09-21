import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/permission/permission.dart';
import '../domain/entities/user/user.dart';
import '../features/authentication/provider/auth_provider.dart';
import '../features/user/provider/user_permission_controller.dart';

final currentUserPermissionsProvider =
    FutureProvider<Set<PermissionKey>>((ref) async {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    authenticated: (User user, DateTime? lastLoginTime) async {
      if (user.role == UserRole.admin || user.role == UserRole.guest) {
        return PermissionCatalog.defaultPermissionsForUserRole(user.role);
      }

      final permissions = ref.watch(userPermissionControllerProvider(user.id));
      if (permissions.hasError) {
        throw permissions.error!;
      }
      if (permissions.hasValue) {
        return permissions.value!;
      }
      return ref.watch(userPermissionControllerProvider(user.id).future);
    },
    unauthenticated: () async => <PermissionKey>{},
    initial: () async => <PermissionKey>{},
  );
});

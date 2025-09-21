import 'package:flutter_test/flutter_test.dart';

import 'package:sample_app/domain/entities/permission/permission.dart';
import 'package:sample_app/domain/entities/user/user.dart';
import 'package:sample_app/features/home/menu_manager.dart';

void main() {
  group('MenuManager.getMenuGroups', () {
    test('applies fallback order when preferred order misses new groups', () {
      final user = User(
        id: 1,
        username: 'admin',
        role: UserRole.admin,
      );

      final groups = MenuManager.getMenuGroups(
        user: user,
        permissions: PermissionCatalog.defaultPermissionsForUserRole(user.role),
        preferredOrder: const [MenuGroupId.priceAndOrder],
      );

      expect(
        groups.map((group) => group.id).toList(),
        const [
          MenuGroupId.priceAndOrder,
          MenuGroupId.productManagement,
          MenuGroupId.systemAdministration,
          MenuGroupId.dataManagement,
        ],
      );
    });
  });
}

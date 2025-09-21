import 'package:flutter/material.dart';

import '../../domain/entities/permission/permission.dart';
import '../../domain/entities/user/user.dart';
import '../../routes/app_router.dart';

// Model cho menu item
class MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback destinationCallback;
  final Set<PermissionKey> requiredPermissions;

  MenuItem({
    required this.title,
    required this.icon,
    required this.destinationCallback,
    this.requiredPermissions = const {},
  });
}

// Group menu items by business category
class MenuGroup {
  final String title;
  final List<MenuItem> items;
  MenuGroup({required this.title, required this.items});
}

/// Class quản lý menu cho từng UserRole
class MenuManager {
  static List<MenuGroup> getMenuGroups({
    required User user,
    required Set<PermissionKey> permissions,
  }) {
    final effectivePermissions = <PermissionKey>{
      if (user.role == UserRole.admin || user.role == UserRole.guest)
        ...PermissionCatalog.defaultPermissionsForUserRole(user.role)
      else
        ...permissions,
    };

    final groups = <MenuGroup>[];

    for (final baseGroup in _baseMenuGroups()) {
      final filteredItems = baseGroup.items
          .where((item) =>
              item.requiredPermissions.every(effectivePermissions.contains))
          .toList();

      if (filteredItems.isNotEmpty) {
        groups.add(MenuGroup(title: baseGroup.title, items: filteredItems));
      }
    }

    return groups;
  }

  static List<MenuGroup> _baseMenuGroups() {
    return [
      MenuGroup(
        title: 'Quản lý sản phẩm',
        items: [
          MenuItem(
            title: 'Sản phẩm',
            icon: Icons.inventory,
            destinationCallback: () {
              appRouter.goToProductList();
            },
            requiredPermissions: {PermissionKey.productView},
          ),
          MenuItem(
            title: 'Kiểm kê',
            icon: Icons.fact_check,
            destinationCallback: () {
              appRouter.goToCheckSessions();
            },
            requiredPermissions: {PermissionKey.inventoryView},
          ),
          MenuItem(
            title: 'Danh mục',
            icon: Icons.category,
            destinationCallback: () {
              appRouter.goToCategory();
            },
            requiredPermissions: {PermissionKey.categoryView},
          ),
          MenuItem(
            title: 'Đơn vị/Quy cách',
            icon: Icons.straighten,
            destinationCallback: () {
              appRouter.goToUnit();
            },
            requiredPermissions: {PermissionKey.unitView},
          ),
        ],
      ),
      MenuGroup(
        title: 'Giá & Đơn hàng',
        items: [
          MenuItem(
            title: 'Giá bán',
            icon: Icons.price_change,
            destinationCallback: () {
              appRouter.goToConfigProductPrice();
            },
            requiredPermissions: {PermissionKey.priceUpdate},
          ),
          MenuItem(
            title: 'Tạo đơn hàng',
            icon: Icons.add_shopping_cart,
            destinationCallback: () {
              appRouter.goToCreateOrder();
            },
            requiredPermissions: {PermissionKey.orderCreate},
          ),
          MenuItem(
            title: 'Danh sách đơn hàng',
            icon: Icons.assignment_turned_in,
            destinationCallback: () {
              appRouter.goToOrderStatusList();
            },
            requiredPermissions: {PermissionKey.orderView},
          ),
        ],
      ),
      MenuGroup(
        title: 'Quản trị hệ thống',
        items: [
          MenuItem(
            title: 'Quản lý người dùng',
            icon: Icons.people,
            destinationCallback: () {
              appRouter.goToUserManagement();
            },
            requiredPermissions: {PermissionKey.userManage},
          ),
          MenuItem(
            title: 'Báo cáo thống kê',
            icon: Icons.analytics,
            destinationCallback: () {
              appRouter.goToReport();
            },
            requiredPermissions: {PermissionKey.reportView},
          ),
        ],
      ),
      MenuGroup(
        title: 'Quản lý dữ liệu',
        items: [
          MenuItem(
            title: 'Tạo dữ liệu mẫu',
            icon: Icons.dataset,
            destinationCallback: () {
              appRouter.goToCreateSampleData();
            },
            requiredPermissions: {PermissionKey.dataCreateSample},
          ),
          MenuItem(
            title: 'Nhập dữ liệu',
            icon: Icons.file_upload,
            destinationCallback: () {
              appRouter.goToImportData();
            },
            requiredPermissions: {PermissionKey.dataImport},
          ),
          MenuItem(
            title: 'Xuất dữ liệu',
            icon: Icons.file_download,
            destinationCallback: () {
              appRouter.goToExportData();
            },
            requiredPermissions: {PermissionKey.dataExport},
          ),
          MenuItem(
            title: 'Xóa dữ liệu',
            icon: Icons.delete_forever,
            destinationCallback: () {
              appRouter.goToDeleteData();
            },
            requiredPermissions: {PermissionKey.dataDelete},
          ),
        ],
      ),
    ];
  }
}

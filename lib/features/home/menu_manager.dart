import 'package:flutter/material.dart';

import '../../domain/entities/permission/permission.dart';
import '../../domain/entities/user/user.dart';
import '../../resources/index.dart';
import '../../routes/app_router.dart';

// Model cho menu item
enum MenuItemId {
  productList,
  inventory,
  categories,
  units,
  priceConfig,
  orderCreate,
  orderList,
  userManagement,
  report,
  createSampleData,
  importData,
  exportData,
  deleteData,
}

class MenuItem {
  final MenuItemId id;
  final String title;
  final IconData icon;
  final VoidCallback destinationCallback;
  final Set<PermissionKey> requiredPermissions;

  MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.destinationCallback,
    this.requiredPermissions = const {},
  });
}

enum MenuGroupId {
  productManagement,
  priceAndOrder,
  systemAdministration,
  dataManagement,
}

// Group menu items by business category
class MenuGroup {
  final MenuGroupId id;
  final String title;
  final List<MenuItem> items;
  MenuGroup({required this.id, required this.title, required this.items});
}

/// Class quản lý menu cho từng UserRole
class MenuManager {
  static List<MenuGroup> getMenuGroups({
    BuildContext? context,
    required User user,
    required Set<PermissionKey> permissions,
    List<MenuGroupId>? preferredOrder,
  }) {
    final effectivePermissions = <PermissionKey>{
      if (user.role == UserRole.admin || user.role == UserRole.guest)
        ...PermissionCatalog.defaultPermissionsForUserRole(user.role)
      else
        ...permissions,
    };

    final groups = <MenuGroup>[];

    for (final baseGroup in _baseMenuGroups(context)) {
      final filteredItems = baseGroup.items
          .where((item) =>
              item.requiredPermissions.every(effectivePermissions.contains))
          .toList();

      if (filteredItems.isNotEmpty) {
        groups.add(MenuGroup(
          id: baseGroup.id,
          title: baseGroup.title,
          items: filteredItems,
        ));
      }
    }

    if (preferredOrder != null && preferredOrder.isNotEmpty) {
      final fallbackPositions = <MenuGroupId, int>{
        for (var i = 0; i < groups.length; i++) groups[i].id: i,
      };
      groups.sort((a, b) {
        final indexA = preferredOrder.indexOf(a.id);
        final indexB = preferredOrder.indexOf(b.id);
        final valueA = indexA >= 0
            ? indexA
            : preferredOrder.length + (fallbackPositions[a.id] ?? 0);
        final valueB = indexB >= 0
            ? indexB
            : preferredOrder.length + (fallbackPositions[b.id] ?? 0);
        return valueA.compareTo(valueB);
      });
    }

    return groups;
  }

  static List<MenuGroup> _baseMenuGroups(BuildContext? context) {
    return [
      MenuGroup(
        id: MenuGroupId.productManagement,
        title: _t(
          context,
          key: LKey.homeMenuGroupProductManagement,
          fallback: 'Product management',
        ),
        items: [
          MenuItem(
            id: MenuItemId.productList,
            title: _t(
              context,
              key: LKey.homeMenuItemProducts,
              fallback: 'Products',
            ),
            icon: Icons.inventory,
            destinationCallback: () {
              appRouter.goToProductList();
            },
            requiredPermissions: {PermissionKey.productView},
          ),
          MenuItem(
            id: MenuItemId.inventory,
            title: _t(
              context,
              key: LKey.homeMenuItemInventory,
              fallback: 'Inventory',
            ),
            icon: Icons.fact_check,
            destinationCallback: () {
              appRouter.goToCheckSessions();
            },
            requiredPermissions: {PermissionKey.inventoryView},
          ),
          MenuItem(
            id: MenuItemId.categories,
            title: _t(
              context,
              key: LKey.homeMenuItemCategories,
              fallback: 'Categories',
            ),
            icon: Icons.category,
            destinationCallback: () {
              appRouter.goToCategory();
            },
            requiredPermissions: {PermissionKey.categoryView},
          ),
          MenuItem(
            id: MenuItemId.units,
            title: _t(
              context,
              key: LKey.homeMenuItemUnits,
              fallback: 'Units',
            ),
            icon: Icons.straighten,
            destinationCallback: () {
              appRouter.goToUnit();
            },
            requiredPermissions: {PermissionKey.unitView},
          ),
        ],
      ),
      MenuGroup(
        id: MenuGroupId.priceAndOrder,
        title: _t(
          context,
          key: LKey.homeMenuGroupPriceOrder,
          fallback: 'Pricing & Orders',
        ),
        items: [
          MenuItem(
            id: MenuItemId.priceConfig,
            title: _t(
              context,
              key: LKey.homeMenuItemPricing,
              fallback: 'Pricing',
            ),
            icon: Icons.price_change,
            destinationCallback: () {
              appRouter.goToConfigProductPrice();
            },
            requiredPermissions: {PermissionKey.priceUpdate},
          ),
          MenuItem(
            id: MenuItemId.orderCreate,
            title: _t(
              context,
              key: LKey.homeMenuItemCreateOrder,
              fallback: 'Create order',
            ),
            icon: Icons.add_shopping_cart,
            destinationCallback: () {
              appRouter.goToCreateOrder();
            },
            requiredPermissions: {PermissionKey.orderCreate},
          ),
          MenuItem(
            id: MenuItemId.orderList,
            title: _t(
              context,
              key: LKey.homeMenuItemOrderList,
              fallback: 'Order list',
            ),
            icon: Icons.assignment_turned_in,
            destinationCallback: () {
              appRouter.goToOrderStatusList();
            },
            requiredPermissions: {PermissionKey.orderView},
          ),
        ],
      ),
      MenuGroup(
        id: MenuGroupId.systemAdministration,
        title: _t(
          context,
          key: LKey.homeMenuGroupSystemAdministration,
          fallback: 'System administration',
        ),
        items: [
          MenuItem(
            id: MenuItemId.userManagement,
            title: _t(
              context,
              key: LKey.homeMenuItemUserManagement,
              fallback: 'User management',
            ),
            icon: Icons.people,
            destinationCallback: () {
              appRouter.goToUserManagement();
            },
            requiredPermissions: {PermissionKey.userManage},
          ),
          MenuItem(
            id: MenuItemId.report,
            title: _t(
              context,
              key: LKey.homeMenuItemReports,
              fallback: 'Reports',
            ),
            icon: Icons.analytics,
            destinationCallback: () {
              appRouter.goToReport();
            },
            requiredPermissions: {PermissionKey.reportView},
          ),
        ],
      ),
      MenuGroup(
        id: MenuGroupId.dataManagement,
        title: _t(
          context,
          key: LKey.homeMenuGroupDataManagement,
          fallback: 'Data management',
        ),
        items: [
          MenuItem(
            id: MenuItemId.createSampleData,
            title: _t(
              context,
              key: LKey.homeMenuItemCreateSampleData,
              fallback: 'Create sample data',
            ),
            icon: Icons.dataset,
            destinationCallback: () {
              appRouter.goToCreateSampleData();
            },
            requiredPermissions: {PermissionKey.dataCreateSample},
          ),
          MenuItem(
            id: MenuItemId.importData,
            title: _t(
              context,
              key: LKey.homeMenuItemImportData,
              fallback: 'Import data',
            ),
            icon: Icons.file_upload,
            destinationCallback: () {
              appRouter.goToImportData();
            },
            requiredPermissions: {PermissionKey.dataImport},
          ),
          MenuItem(
            id: MenuItemId.exportData,
            title: _t(
              context,
              key: LKey.homeMenuItemExportData,
              fallback: 'Export data',
            ),
            icon: Icons.file_download,
            destinationCallback: () {
              appRouter.goToExportData();
            },
            requiredPermissions: {PermissionKey.dataExport},
          ),
          MenuItem(
            id: MenuItemId.deleteData,
            title: _t(
              context,
              key: LKey.homeMenuItemDeleteData,
              fallback: 'Delete data',
            ),
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

  static String titleFor(MenuGroupId id, BuildContext context) {
    switch (id) {
      case MenuGroupId.productManagement:
        return _t(
          context,
          key: LKey.homeMenuGroupProductManagement,
          fallback: 'Product management',
        );
      case MenuGroupId.priceAndOrder:
        return _t(
          context,
          key: LKey.homeMenuGroupPriceOrder,
          fallback: 'Pricing & Orders',
        );
      case MenuGroupId.systemAdministration:
        return _t(
          context,
          key: LKey.homeMenuGroupSystemAdministration,
          fallback: 'System administration',
        );
      case MenuGroupId.dataManagement:
        return _t(
          context,
          key: LKey.homeMenuGroupDataManagement,
          fallback: 'Data management',
        );
    }
  }

  static String _t(
    BuildContext? context, {
    required String key,
    required String fallback,
    Map<String, String>? namedArgs,
  }) {
    if (context != null) {
      return key.tr(context: context, namedArgs: namedArgs);
    }

    if (namedArgs == null || namedArgs.isEmpty) {
      return fallback;
    }

    var result = fallback;
    namedArgs.forEach((k, v) {
      result = result.replaceAll('{$k}', v);
    });
    return result;
  }
}

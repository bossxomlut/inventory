import 'package:flutter/material.dart';

import '../user/user.dart';

/// Logical grouping for permissions so UI can cluster related actions.
enum PermissionGroupId {
  product,
  inventory,
  order,
  pricing,
  dataManagement,
  reports,
  system,
}

extension PermissionGroupIdX on PermissionGroupId {
  String get title {
    switch (this) {
      case PermissionGroupId.product:
        return 'Product management';
      case PermissionGroupId.inventory:
        return 'Stocktake';
      case PermissionGroupId.order:
        return 'Orders';
      case PermissionGroupId.pricing:
        return 'Pricing';
      case PermissionGroupId.dataManagement:
        return 'Data management';
      case PermissionGroupId.reports:
        return 'Reports';
      case PermissionGroupId.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case PermissionGroupId.product:
        return Icons.inventory_2_outlined;
      case PermissionGroupId.inventory:
        return Icons.fact_check_outlined;
      case PermissionGroupId.order:
        return Icons.shopping_cart_checkout_outlined;
      case PermissionGroupId.pricing:
        return Icons.price_change_outlined;
      case PermissionGroupId.dataManagement:
        return Icons.storage_outlined;
      case PermissionGroupId.reports:
        return Icons.analytics_outlined;
      case PermissionGroupId.system:
        return Icons.admin_panel_settings_outlined;
    }
  }
}

/// Atomic actions that can be granted to a user.
enum PermissionKey {
  productView,
  productCreate,
  productUpdate,
  productDelete,
  categoryView,
  categoryCreate,
  categoryUpdate,
  categoryDelete,
  unitView,
  unitCreate,
  unitUpdate,
  unitDelete,
  inventoryView,
  inventoryCreateSession,
  inventoryFinalizeSession,
  priceUpdate,
  orderView,
  orderViewDraft,
  orderViewConfirmed,
  orderViewDone,
  orderViewCancelled,
  orderCreate,
  orderDelete,
  orderConfirm,
  orderComplete,
  orderCancel,
  dataCreateSample,
  dataImport,
  dataExport,
  dataDelete,
  reportView,
  userManage,
  permissionManage,
}

class PermissionDefinition {
  const PermissionDefinition({
    required this.key,
    required this.group,
    required this.title,
    this.description,
    this.defaultEnabledForUser = false,
  });

  final PermissionKey key;
  final PermissionGroupId group;
  final String title;
  final String? description;
  final bool defaultEnabledForUser;
}

class PermissionCatalog {
  static const List<PermissionDefinition> definitions = [
    PermissionDefinition(
      key: PermissionKey.productView,
      group: PermissionGroupId.product,
      title: 'View products',
      description: 'Access product lists and details.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.productCreate,
      group: PermissionGroupId.product,
      title: 'Create products',
      description: 'Add new products to the catalog.',
    ),
    PermissionDefinition(
      key: PermissionKey.productUpdate,
      group: PermissionGroupId.product,
      title: 'Update products',
      description: 'Edit product information.',
    ),
    PermissionDefinition(
      key: PermissionKey.productDelete,
      group: PermissionGroupId.product,
      title: 'Delete products',
      description: 'Remove products from the catalog.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryView,
      group: PermissionGroupId.product,
      title: 'View categories',
      description: 'Access product categories.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryCreate,
      group: PermissionGroupId.product,
      title: 'Create categories',
      description: 'Add new product categories.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryUpdate,
      group: PermissionGroupId.product,
      title: 'Update categories',
      description: 'Modify existing category information.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryDelete,
      group: PermissionGroupId.product,
      title: 'Delete categories',
      description: 'Remove unused categories.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitView,
      group: PermissionGroupId.product,
      title: 'View units',
      description: 'Access measurement units and packaging.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitCreate,
      group: PermissionGroupId.product,
      title: 'Create units',
      description: 'Add new measurement units.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitUpdate,
      group: PermissionGroupId.product,
      title: 'Update units',
      description: 'Edit existing measurement units.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitDelete,
      group: PermissionGroupId.product,
      title: 'Delete units',
      description: 'Remove unused measurement units.',
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryView,
      group: PermissionGroupId.inventory,
      title: 'View stocktake sessions',
      description: 'Access stocktake sessions and results.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryCreateSession,
      group: PermissionGroupId.inventory,
      title: 'Create stocktake sessions',
      description: 'Start new stocktake sessions.',
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryFinalizeSession,
      group: PermissionGroupId.inventory,
      title: 'Complete stocktake sessions',
      description: 'Finalize and lock stocktake sessions.',
    ),
    PermissionDefinition(
      key: PermissionKey.priceUpdate,
      group: PermissionGroupId.pricing,
      title: 'Update prices',
      description: 'Modify product selling prices.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderCreate,
      group: PermissionGroupId.order,
      title: 'Create orders',
      description: 'Create new orders.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderView,
      group: PermissionGroupId.order,
      title: 'View orders',
      description: 'View order lists and details.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderViewDraft,
      group: PermissionGroupId.order,
      title: 'View draft orders',
      description: 'Access orders in Draft status.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderViewConfirmed,
      group: PermissionGroupId.order,
      title: 'View confirmed orders',
      description: 'Access orders pending processing.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderViewDone,
      group: PermissionGroupId.order,
      title: 'View completed orders',
      description: 'Access orders that have been completed.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderViewCancelled,
      group: PermissionGroupId.order,
      title: 'View cancelled orders',
      description: 'Access orders that were cancelled.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderDelete,
      group: PermissionGroupId.order,
      title: 'Delete orders',
      description: 'Remove orders from the system.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderConfirm,
      group: PermissionGroupId.order,
      title: 'Confirm orders',
      description: 'Move orders to the Pending or In progress statuses.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderComplete,
      group: PermissionGroupId.order,
      title: 'Complete orders',
      description: 'Move orders to the Completed status.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderCancel,
      group: PermissionGroupId.order,
      title: 'Cancel orders',
      description: 'Move orders to the Cancelled status.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataCreateSample,
      group: PermissionGroupId.dataManagement,
      title: 'Create sample data',
      description: 'Populate the system with sample data.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataImport,
      group: PermissionGroupId.dataManagement,
      title: 'Import data',
      description: 'Import data from files or other sources.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataExport,
      group: PermissionGroupId.dataManagement,
      title: 'Export data',
      description: 'Export data to a file.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataDelete,
      group: PermissionGroupId.dataManagement,
      title: 'Delete data',
      description: 'Remove existing data from the system.',
    ),
    PermissionDefinition(
      key: PermissionKey.reportView,
      group: PermissionGroupId.reports,
      title: 'View reports',
      description: 'Access analytical reports.',
    ),
    PermissionDefinition(
      key: PermissionKey.userManage,
      group: PermissionGroupId.system,
      title: 'Manage users',
      description: 'Access user lists and activate accounts.',
    ),
    PermissionDefinition(
      key: PermissionKey.permissionManage,
      group: PermissionGroupId.system,
      title: 'Manage permissions',
      description: 'Update user access rights.',
    ),
  ];

  static Set<PermissionKey> defaultPermissionsForUserRole(UserRole role) {
    if (role == UserRole.admin || role == UserRole.guest) {
      return definitions.map((def) => def.key).toSet();
    }
    return definitions
        .where((definition) => definition.defaultEnabledForUser)
        .map((definition) => definition.key)
        .toSet();
  }

  static PermissionDefinition definitionOf(PermissionKey key) {
    return definitions.firstWhere((definition) => definition.key == key);
  }

  static Map<PermissionGroupId, List<PermissionDefinition>>
      groupedDefinitions() {
    final map = <PermissionGroupId, List<PermissionDefinition>>{};
    for (final definition in definitions) {
      map.putIfAbsent(definition.group, () => []).add(definition);
    }
    return map;
  }
}

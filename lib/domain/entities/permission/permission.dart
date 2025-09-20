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
        return 'Quản lý sản phẩm';
      case PermissionGroupId.inventory:
        return 'Kiểm kê';
      case PermissionGroupId.order:
        return 'Đơn hàng';
      case PermissionGroupId.pricing:
        return 'Giá bán';
      case PermissionGroupId.dataManagement:
        return 'Quản lý dữ liệu';
      case PermissionGroupId.reports:
        return 'Báo cáo';
      case PermissionGroupId.system:
        return 'Hệ thống';
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
  productManage,
  categoryManage,
  unitManage,
  inventoryView,
  inventoryManage,
  priceConfigure,
  orderCreate,
  orderView,
  orderManage,
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
      title: 'Xem danh sách sản phẩm',
      description: 'Truy cập danh sách và chi tiết sản phẩm.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.productManage,
      group: PermissionGroupId.product,
      title: 'Quản lý sản phẩm',
      description: 'Tạo, chỉnh sửa, hoặc xóa sản phẩm.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryManage,
      group: PermissionGroupId.product,
      title: 'Quản lý danh mục',
      description: 'Tạo và chỉnh sửa danh mục sản phẩm.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitManage,
      group: PermissionGroupId.product,
      title: 'Quản lý đơn vị/ quy cách',
      description: 'Tạo hoặc chỉnh sửa đơn vị tính.',
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryView,
      group: PermissionGroupId.inventory,
      title: 'Xem phiên kiểm kê',
      description: 'Truy cập các phiên kiểm kê và kết quả.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryManage,
      group: PermissionGroupId.inventory,
      title: 'Tạo/ cập nhật kiểm kê',
      description: 'Khởi tạo và cập nhật các phiên kiểm kê.',
    ),
    PermissionDefinition(
      key: PermissionKey.priceConfigure,
      group: PermissionGroupId.pricing,
      title: 'Cấu hình giá bán',
      description: 'Xem và chỉnh sửa bảng giá sản phẩm.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderCreate,
      group: PermissionGroupId.order,
      title: 'Tạo đơn hàng',
      description: 'Khởi tạo đơn hàng mới.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderView,
      group: PermissionGroupId.order,
      title: 'Xem danh sách đơn hàng',
      description: 'Xem danh sách và chi tiết đơn hàng.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderManage,
      group: PermissionGroupId.order,
      title: 'Cập nhật trạng thái đơn hàng',
      description: 'Thay đổi trạng thái và xử lý đơn hàng.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataCreateSample,
      group: PermissionGroupId.dataManagement,
      title: 'Tạo dữ liệu mẫu',
      description: 'Khởi tạo dữ liệu mẫu cho hệ thống.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataImport,
      group: PermissionGroupId.dataManagement,
      title: 'Nhập dữ liệu',
      description: 'Nhập dữ liệu từ file hoặc nguồn khác.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataExport,
      group: PermissionGroupId.dataManagement,
      title: 'Xuất dữ liệu',
      description: 'Xuất dữ liệu ra file.',
    ),
    PermissionDefinition(
      key: PermissionKey.dataDelete,
      group: PermissionGroupId.dataManagement,
      title: 'Xóa dữ liệu',
      description: 'Xóa dữ liệu hiện có trong hệ thống.',
    ),
    PermissionDefinition(
      key: PermissionKey.reportView,
      group: PermissionGroupId.reports,
      title: 'Xem báo cáo',
      description: 'Truy cập các báo cáo thống kê.',
    ),
    PermissionDefinition(
      key: PermissionKey.userManage,
      group: PermissionGroupId.system,
      title: 'Quản lý người dùng',
      description: 'Truy cập danh sách và kích hoạt người dùng.',
    ),
    PermissionDefinition(
      key: PermissionKey.permissionManage,
      group: PermissionGroupId.system,
      title: 'Phân quyền người dùng',
      description: 'Chỉnh sửa quyền truy cập của người dùng.',
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

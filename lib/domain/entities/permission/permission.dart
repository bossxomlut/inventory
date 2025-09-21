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
      title: 'Xem sản phẩm',
      description: 'Truy cập danh sách và chi tiết sản phẩm.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.productCreate,
      group: PermissionGroupId.product,
      title: 'Tạo sản phẩm',
      description: 'Tạo mới sản phẩm trong hệ thống.',
    ),
    PermissionDefinition(
      key: PermissionKey.productUpdate,
      group: PermissionGroupId.product,
      title: 'Cập nhật sản phẩm',
      description: 'Chỉnh sửa thông tin sản phẩm.',
    ),
    PermissionDefinition(
      key: PermissionKey.productDelete,
      group: PermissionGroupId.product,
      title: 'Xóa sản phẩm',
      description: 'Xóa sản phẩm khỏi hệ thống.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryView,
      group: PermissionGroupId.product,
      title: 'Xem danh mục',
      description: 'Truy cập danh mục sản phẩm.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryCreate,
      group: PermissionGroupId.product,
      title: 'Tạo danh mục',
      description: 'Tạo danh mục sản phẩm mới.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryUpdate,
      group: PermissionGroupId.product,
      title: 'Cập nhật danh mục',
      description: 'Chỉnh sửa thông tin danh mục.',
    ),
    PermissionDefinition(
      key: PermissionKey.categoryDelete,
      group: PermissionGroupId.product,
      title: 'Xóa danh mục',
      description: 'Xóa danh mục không sử dụng.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitView,
      group: PermissionGroupId.product,
      title: 'Xem đơn vị/ quy cách',
      description: 'Truy cập danh sách các đơn vị/quy cách.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitCreate,
      group: PermissionGroupId.product,
      title: 'Tạo đơn vị/ quy cách',
      description: 'Thêm đơn vị/quy cách mới.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitUpdate,
      group: PermissionGroupId.product,
      title: 'Cập nhật đơn vị/ quy cách',
      description: 'Chỉnh sửa đơn vị/quy cách hiện tại.',
    ),
    PermissionDefinition(
      key: PermissionKey.unitDelete,
      group: PermissionGroupId.product,
      title: 'Xóa đơn vị/ quy cách',
      description: 'Xóa các đơn vị/quy cách không còn sử dụng.',
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryView,
      group: PermissionGroupId.inventory,
      title: 'Xem phiên kiểm kê',
      description: 'Truy cập các phiên kiểm kê và kết quả.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryCreateSession,
      group: PermissionGroupId.inventory,
      title: 'Tạo phiên kiểm kê',
      description: 'Khởi tạo các phiên kiểm kê mới.',
    ),
    PermissionDefinition(
      key: PermissionKey.inventoryFinalizeSession,
      group: PermissionGroupId.inventory,
      title: 'Hoàn tất kiểm kê',
      description: 'Khóa và hoàn tất các phiên kiểm kê.',
    ),
    PermissionDefinition(
      key: PermissionKey.priceUpdate,
      group: PermissionGroupId.pricing,
      title: 'Cập nhật giá bán',
      description: 'Chỉnh sửa giá bán của sản phẩm.',
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
      key: PermissionKey.orderViewDraft,
      group: PermissionGroupId.order,
      title: 'Xem đơn hàng nháp',
      description: 'Truy cập các đơn hàng ở trạng thái Nháp.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderViewConfirmed,
      group: PermissionGroupId.order,
      title: 'Xem đơn hàng chờ xử lý',
      description: 'Truy cập các đơn hàng đang chờ xử lý.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderViewDone,
      group: PermissionGroupId.order,
      title: 'Xem đơn hàng hoàn tất',
      description: 'Truy cập các đơn hàng đã hoàn tất.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderViewCancelled,
      group: PermissionGroupId.order,
      title: 'Xem đơn hàng đã hủy',
      description: 'Truy cập các đơn hàng đã hủy.',
      defaultEnabledForUser: true,
    ),
    PermissionDefinition(
      key: PermissionKey.orderDelete,
      group: PermissionGroupId.order,
      title: 'Xóa đơn hàng',
      description: 'Xóa đơn hàng khỏi hệ thống.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderConfirm,
      group: PermissionGroupId.order,
      title: 'Xác nhận đơn hàng',
      description: 'Thay đổi trạng thái đơn hàng sang Chờ xử lý/Đang xử lý.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderComplete,
      group: PermissionGroupId.order,
      title: 'Hoàn tất đơn hàng',
      description: 'Chuyển đơn hàng sang trạng thái Hoàn tất.',
    ),
    PermissionDefinition(
      key: PermissionKey.orderCancel,
      group: PermissionGroupId.order,
      title: 'Hủy đơn hàng',
      description: 'Chuyển đơn hàng sang trạng thái Hủy.',
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

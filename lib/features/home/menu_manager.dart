import 'package:flutter/material.dart';

import '../../domain/entities/user/user.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/toast.dart';

// Model cho menu item
class MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback destinationCallback;

  MenuItem({
    required this.title,
    required this.icon,
    required this.destinationCallback,
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
  static List<MenuGroup> getMenuGroupsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.guest: // Guest có menu giống Admin
        return _getAdminMenuGroups();
      case UserRole.user:
        return _getUserMenuGroups();
    }
  }

  /// Menu dành cho Admin và Guest
  static List<MenuGroup> _getAdminMenuGroups() {
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
          ),
          MenuItem(
            title: 'Kiểm kê',
            icon: Icons.fact_check,
            destinationCallback: () {
              appRouter.goToCheckSessions();
            },
          ),
          MenuItem(
            title: 'Danh mục',
            icon: Icons.category,
            destinationCallback: () {
              appRouter.goToCategory();
            },
          ),
          MenuItem(
            title: 'Đơn vị/Quy cách',
            icon: Icons.straighten,
            destinationCallback: () {
              appRouter.goToUnit();
            },
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
          ),
          MenuItem(
            title: 'Tạo đơn hàng',
            icon: Icons.add_shopping_cart,
            destinationCallback: () {
              appRouter.goToCreateOrder();
            },
          ),
          MenuItem(
            title: 'Danh sách đơn hàng',
            icon: Icons.assignment_turned_in,
            destinationCallback: () {
              appRouter.goToOrderStatusList();
            },
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
          ),
          MenuItem(
            title: 'Báo cáo thống kê',
            icon: Icons.analytics,
            destinationCallback: () {
              appRouter.goToReport();
              // showInfoSnackBar(appRouter.context!, 'Chức năng báo cáo thống kê đang được phát triển');
            },
          ),
        ],
      ),
    ];
  }

  /// Menu dành cho User (giới hạn hơn)
  static List<MenuGroup> _getUserMenuGroups() {
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
          ),
          MenuItem(
            title: 'Kiểm kê',
            icon: Icons.fact_check,
            destinationCallback: () {
              appRouter.goToCheckSessions();
            },
          ),
        ],
      ),
      MenuGroup(
        title: 'Đơn hàng',
        items: [
          MenuItem(
            title: 'Tạo đơn hàng',
            icon: Icons.add_shopping_cart,
            destinationCallback: () {
              appRouter.goToCreateOrder();
            },
          ),
          MenuItem(
            title: 'Danh sách đơn hàng',
            icon: Icons.assignment_turned_in,
            destinationCallback: () {
              appRouter.goToOrderStatusList();
            },
          ),
        ],
      ),
    ];
  }
}

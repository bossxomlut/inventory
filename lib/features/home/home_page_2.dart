import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/index.dart';
import '../../provider/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';

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

@RoutePage()
class HomePage2 extends ConsumerWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final theme = context.appTheme;
    return user.when(
        authenticated: (User user, DateTime? lastLoginTime) {
          List<MenuGroup> menuGroups = [
            MenuGroup(
              title: 'Quản lý sản phẩm',
              items: [
                MenuItem(
                  title: 'Quản lý sản phẩm',
                  icon: Icons.inventory,
                  destinationCallback: () {
                    appRouter.goToProductList();
                  },
                ),
                MenuItem(
                  title: 'Kiểm kê sản phẩm',
                  icon: Icons.fact_check,
                  destinationCallback: () {
                    appRouter.goToCheckSessions();
                  },
                ),
                MenuItem(
                  title: 'Quản lý danh mục',
                  icon: Icons.category,
                  destinationCallback: () {
                    appRouter.goToCategory();
                  },
                ),
                MenuItem(
                  title: 'Quản lý đơn vị',
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
                  title: 'Quản lý giá bán',
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
                  title: 'Trạng thái đơn hàng',
                  icon: Icons.assignment_turned_in,
                  destinationCallback: () {
                    // TODO: Implement navigation to Order Status Management page
                  },
                ),
              ],
            ),
            // MenuGroup(
            //   title: 'Khác',
            //   items: [
            //     MenuItem(
            //       title: 'Giao dịch',
            //       icon: Icons.receipt_long,
            //       destinationCallback: () {},
            //     ),
            //     if (user.role == UserRole.admin)
            //       MenuItem(
            //         title: 'Người dùng',
            //         icon: Icons.person,
            //         destinationCallback: () {},
            //       ),
            //   ],
            // ),
          ];

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: context.appTheme.colorSecondary,
                          child: Icon(Icons.person, size: 32, color: context.appTheme.colorPrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào,',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                              ),
                              Text(
                                user.username,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: theme.colorIcon,
                          ),
                          onPressed: () {
                            appRouter.goToSetting();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Modern grid menu
                    Expanded(
                      child: ListView.separated(
                        itemCount: menuGroups.length,
                        separatorBuilder: (context, idx) => const SizedBox(height: 18),
                        itemBuilder: (context, groupIdx) {
                          final group = menuGroups[groupIdx];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Text(
                                  group.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: context.appTheme.colorPrimary,
                                  ),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.95,
                                ),
                                itemCount: group.items.length,
                                itemBuilder: (context, index) {
                                  final item = group.items[index];
                                  return InkWell(
                                    onTap: item.destinationCallback,
                                    borderRadius: BorderRadius.circular(18),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: LinearGradient(
                                          colors: [
                                            context.appTheme.colorSecondary.withOpacity(0.5),
                                            context.appTheme.colorSecondary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.appTheme.colorPrimary.withOpacity(0.08),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: context.appTheme.colorPrimary.withOpacity(0.10),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Icon(
                                              item.icon,
                                              size: 36,
                                              color: context.appTheme.colorPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: context.appTheme.colorPrimary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        unauthenticated: () => Scaffold(
              appBar: AppBar(
                title: const Text('Quản lý kho'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Vui lòng đăng nhập để sử dụng ứng dụng.'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        appRouter.goToLogin();
                      },
                      child: Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
        initial: () => const SizedBox());
  }
}

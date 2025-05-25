import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/index.dart';
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

@RoutePage()
class HomePage2 extends ConsumerWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    return user.when(
        authenticated: (User user, DateTime? lastLoginTime) {
          List<MenuItem> menuItems = <MenuItem>[];
          switch (user.role) {
            case UserRole.admin:
              menuItems = [
                MenuItem(
                  title: 'Products',
                  icon: Icons.inventory,
                  destinationCallback: () {
                    // Chuyển đến trang sản phẩm
                    appRouter.goToProduct();
                  },
                ),
                MenuItem(
                  title: 'Categories',
                  icon: Icons.category,
                  destinationCallback: () {
                    appRouter.goToCategory();
                  },
                ),
                MenuItem(
                  title: 'Warehouses',
                  icon: Icons.warehouse,
                  destinationCallback: () {},
                ),
                MenuItem(
                  title: 'Transactions',
                  icon: Icons.receipt_long,
                  destinationCallback: () {},
                ),
                MenuItem(
                  title: 'Users',
                  icon: Icons.person,
                  destinationCallback: () {},
                ),
              ];
            case UserRole.user:
            case UserRole.guest:
              menuItems = [
                MenuItem(
                  title: 'Products',
                  icon: Icons.inventory,
                  destinationCallback: () {},
                ),
                MenuItem(
                  title: 'Categories',
                  icon: Icons.category,
                  destinationCallback: () {},
                ),
                MenuItem(
                  title: 'Transactions',
                  icon: Icons.receipt_long,
                  destinationCallback: () {},
                ),
              ];
          }

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Inventory App',
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    // Chuyển đến trang cài đặt
                    appRouter.goToSetting();
                    // Xử lý đăng xuất
                    // ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lời chào
                  Text(
                    'Welcome, ${user?.username ?? "Guest"}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu dạng lưới
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 cột
                        crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1, // Tỷ lệ chiều cao/chiều rộng
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              item.destinationCallback();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 48,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        unauthenticated: () => Scaffold(
              appBar: AppBar(
                title: const Text('Inventory App'),
              ),
              body: Center(
                child: Column(
                  children: [
                    Text('Please log in to access the app.'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        appRouter.goToLogin();
                      },
                      child: Text('Log In'),
                    ),
                  ],
                ),
              ),
            ),
        initial: () => const SizedBox());
  }
}

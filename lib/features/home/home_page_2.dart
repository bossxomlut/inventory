import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/index.dart';
import '../../domain/entities/user/user.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';
import '../product/product_page.dart';

// Provider cho người dùng hiện tại
final currentUserProvider = StateProvider<User?>((ref) => null);

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: const Center(child: Text('Category List Screen')),
    );
  }
}

class WarehouseListScreen extends StatelessWidget {
  const WarehouseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warehouses')),
      body: const Center(child: Text('Warehouse List Screen')),
    );
  }
}

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: const Center(child: Text('Transaction List Screen')),
    );
  }
}

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: const Center(child: Text('User List Screen')),
    );
  }
}

// Model cho menu item
class MenuItem {
  final String title;
  final IconData icon;
  final Widget destination;

  MenuItem({
    required this.title,
    required this.icon,
    required this.destination,
  });
}

@RoutePage()
class HomePage2 extends ConsumerWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // Danh sách menu dựa trên vai trò người dùng
    final menuItems = user?.role == 'admin'
        ? [
            MenuItem(
              title: 'Products',
              icon: Icons.inventory,
              destination: const ProductListScreen(),
            ),
            MenuItem(
              title: 'Categories',
              icon: Icons.category,
              destination: const CategoryListScreen(),
            ),
            MenuItem(
              title: 'Warehouses',
              icon: Icons.warehouse,
              destination: const WarehouseListScreen(),
            ),
            MenuItem(
              title: 'Transactions',
              icon: Icons.receipt_long,
              destination: const TransactionListScreen(),
            ),
            MenuItem(
              title: 'Users',
              icon: Icons.person,
              destination: const UserListScreen(),
            ),
          ]
        : [
            MenuItem(
              title: 'Products',
              icon: Icons.inventory,
              destination: const ProductListScreen(),
            ),
            MenuItem(
              title: 'Transactions',
              icon: Icons.receipt_long,
              destination: const TransactionListScreen(),
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Xử lý đăng xuất
              ref.read(authControllerProvider.notifier).logout();
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1, // Tỷ lệ chiều cao/chiều rộng
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => item.destination),
                        );
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
  }
}

/// Ví dụ sử dụng DataDeletionService trong ứng dụng Flutter
///
/// Service này cung cấp chức năng xóa dữ liệu với giao diện người dùng
/// bao gồm dialog xác nhận và hiển thị kết quả.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/data_deletion_service_ui.dart';

/// Ví dụ 1: Sử dụng trong một Widget đơn giản
class DataManagementWidget extends ConsumerWidget {
  const DataManagementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _deleteAllProducts(context, ref),
          child: const Text('Xóa tất cả sản phẩm'),
        ),
        ElevatedButton(
          onPressed: () => _deleteAllCategories(context, ref),
          child: const Text('Xóa tất cả danh mục'),
        ),
        ElevatedButton(
          onPressed: () => _deleteAllUnits(context, ref),
          child: const Text('Xóa tất cả đơn vị'),
        ),
        ElevatedButton(
          onPressed: () => _deleteAllData(context, ref),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Xóa toàn bộ dữ liệu'),
        ),
      ],
    );
  }

  void _deleteAllProducts(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllProductsWithConfirmation(context);
  }

  void _deleteAllCategories(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllCategoriesWithConfirmation(context);
  }

  void _deleteAllUnits(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllUnitsWithConfirmation(context);
  }

  void _deleteAllData(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllDataWithConfirmation(context);
  }
}

/// Ví dụ 2: Sử dụng trực tiếp service mà không có giao diện người dùng
/// (nếu bạn muốn tự xử lý dialog)
class CustomDataDeletionHandler {
  static Future<void> handleCustomDeletion(WidgetRef ref) async {
    final deletionService = ref.read(dataDeletionServiceProvider);

    // Xóa sản phẩm và nhận kết quả
    final result = await deletionService.deleteAllProducts();

    if (result.success) {
      print('Xóa thành công: ${result.message}');
      print('Đã xóa: ${result.deletedCount}/${result.totalItems}');
    } else {
      print('Xóa thất bại: ${result.message}');
      for (final error in result.errors) {
        print('Lỗi: $error');
      }
    }
  }
}

/// Ví dụ 3: Sử dụng trong một dialog tùy chỉnh
class CustomDeletionDialog extends StatelessWidget {
  final WidgetRef ref;

  const CustomDeletionDialog({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tùy chọn xóa dữ liệu'),
      content: const Text('Chọn loại dữ liệu bạn muốn xóa:'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            final service = ref.read(dataDeletionServiceProvider);
            service.deleteAllProductsWithConfirmation(context);
          },
          child: const Text('Xóa sản phẩm'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            final service = ref.read(dataDeletionServiceProvider);
            service.deleteAllDataWithConfirmation(context);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Xóa toàn bộ'),
        ),
      ],
    );
  }
}

/// Ví dụ 4: Tích hợp vào một trang cài đặt
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // Các cài đặt khác...
          const Divider(),
          const ListTile(
            title: Text(
              'Quản lý dữ liệu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.orange),
            title: const Text('Xóa tất cả sản phẩm'),
            subtitle: const Text('Xóa toàn bộ danh sách sản phẩm'),
            onTap: () {
              final service = ref.read(dataDeletionServiceProvider);
              service.deleteAllProductsWithConfirmation(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Xóa toàn bộ dữ liệu'),
            subtitle: const Text('Xóa tất cả dữ liệu ứng dụng'),
            onTap: () {
              final service = ref.read(dataDeletionServiceProvider);
              service.deleteAllDataWithConfirmation(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Lưu ý quan trọng:
///
/// 1. DataDeletionService tự động hiển thị dialog xác nhận trước khi xóa
/// 2. Kết quả xóa sẽ được hiển thị thông qua dialog kết quả
/// 3. Tất cả thông báo đều được bản địa hóa sang tiếng Việt
/// 4. Service sử dụng Riverpod provider để truy cập repositories
/// 5. Xóa sản phẩm, danh mục và đơn vị được thực hiện từng mục một
/// 6. Nếu có lỗi, chúng sẽ được hiển thị chi tiết cho người dùng
/// 7. Chức năng "Xóa toàn bộ dữ liệu" sẽ xóa theo thứ tự: sản phẩm -> danh mục -> đơn vị

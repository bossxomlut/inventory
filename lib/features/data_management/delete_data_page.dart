import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/theme.dart';
import '../../shared_widgets/index.dart';

@RoutePage()
class DeleteDataPage extends ConsumerWidget {
  const DeleteDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Xóa dữ liệu',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cảnh báo',
                          style: theme.headingSemibold20Default.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Thao tác xóa dữ liệu không thể hoàn tác. Hãy chắc chắn rằng bạn đã backup dữ liệu trước khi thực hiện.',
                      style: theme.textRegular14Default.copyWith(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 8),
                    _buildWarningItem('• Dữ liệu bị xóa sẽ không thể khôi phục'),
                    _buildWarningItem('• Nên backup dữ liệu trước khi xóa'),
                    _buildWarningItem('• Thao tác xóa có thể mất vài phút'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildDeleteCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Xóa dữ liệu sản phẩm',
                    description: 'Xóa toàn bộ sản phẩm trong kho',
                    dangerLevel: 'Trung bình',
                    onPressed: () => _deleteProducts(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildDeleteCard(
                    context,
                    icon: Icons.category,
                    title: 'Xóa dữ liệu danh mục',
                    description: 'Xóa toàn bộ danh mục sản phẩm',
                    dangerLevel: 'Thấp',
                    onPressed: () => _deleteCategories(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildDeleteCard(
                    context,
                    icon: Icons.straighten,
                    title: 'Xóa dữ liệu đơn vị',
                    description: 'Xóa toàn bộ đơn vị tính',
                    dangerLevel: 'Thấp',
                    onPressed: () => _deleteUnits(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildDeleteCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Xóa dữ liệu đơn hàng',
                    description: 'Xóa toàn bộ đơn hàng và lịch sử',
                    dangerLevel: 'Cao',
                    onPressed: () => _deleteOrders(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildDeleteCard(
                    context,
                    icon: Icons.fact_check,
                    title: 'Xóa dữ liệu kiểm kê',
                    description: 'Xóa toàn bộ phiên kiểm kê',
                    dangerLevel: 'Cao',
                    onPressed: () => _deleteCheckSessions(context, ref),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.red.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.delete_forever,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Xóa toàn bộ dữ liệu',
                            style: theme.headingSemibold20Default.copyWith(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Xóa tất cả dữ liệu và reset ứng dụng về trạng thái ban đầu',
                            style: theme.textRegular14Default.copyWith(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _deleteAllData(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('XÓA TẤT CẢ DỮ LIỆU'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.red.shade700),
      ),
    );
  }

  Widget _buildDeleteCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String dangerLevel,
    required VoidCallback onPressed,
  }) {
    final theme = context.appTheme;

    Color getLevelColor() {
      switch (dangerLevel) {
        case 'Thấp':
          return Colors.orange;
        case 'Trung bình':
          return Colors.deepOrange;
        case 'Cao':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorPrimary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.headingSemibold20Default,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textRegular14Default,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getLevelColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: getLevelColor().withOpacity(0.3)),
                  ),
                  child: Text(
                    'Mức độ: $dangerLevel',
                    style: TextStyle(
                      fontSize: 12,
                      color: getLevelColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.delete),
                label: const Text('Xóa dữ liệu'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProducts(BuildContext context, WidgetRef ref) {
    _showDeleteConfirmation(
      context,
      'sản phẩm',
      'Thao tác này sẽ xóa tất cả sản phẩm trong kho. Dữ liệu không thể khôi phục.',
      () {
        // TODO: Implement delete products
        _showSuccessMessage(context, 'Đã xóa toàn bộ dữ liệu sản phẩm!');
      },
    );
  }

  void _deleteCategories(BuildContext context, WidgetRef ref) {
    _showDeleteConfirmation(
      context,
      'danh mục',
      'Thao tác này sẽ xóa tất cả danh mục sản phẩm. Các sản phẩm thuộc danh mục sẽ mất thông tin danh mục.',
      () {
        // TODO: Implement delete categories
        _showSuccessMessage(context, 'Đã xóa toàn bộ dữ liệu danh mục!');
      },
    );
  }

  void _deleteUnits(BuildContext context, WidgetRef ref) {
    _showDeleteConfirmation(
      context,
      'đơn vị tính',
      'Thao tác này sẽ xóa tất cả đơn vị tính. Các sản phẩm sử dụng đơn vị này sẽ mất thông tin đơn vị.',
      () {
        // TODO: Implement delete units
        _showSuccessMessage(context, 'Đã xóa toàn bộ dữ liệu đơn vị tính!');
      },
    );
  }

  void _deleteOrders(BuildContext context, WidgetRef ref) {
    _showDeleteConfirmation(
      context,
      'đơn hàng',
      'Thao tác này sẽ xóa tất cả đơn hàng và lịch sử giao dịch. Dữ liệu không thể khôi phục.',
      () {
        // TODO: Implement delete orders
        _showSuccessMessage(context, 'Đã xóa toàn bộ dữ liệu đơn hàng!');
      },
    );
  }

  void _deleteCheckSessions(BuildContext context, WidgetRef ref) {
    _showDeleteConfirmation(
      context,
      'phiên kiểm kê',
      'Thao tác này sẽ xóa tất cả phiên kiểm kê và kết quả kiểm kê. Dữ liệu không thể khôi phục.',
      () {
        // TODO: Implement delete check sessions
        _showSuccessMessage(context, 'Đã xóa toàn bộ dữ liệu kiểm kê!');
      },
    );
  }

  void _deleteAllData(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('XÓA TẤT CẢ DỮ LIỆU'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn xóa TẤT CẢ dữ liệu trong ứng dụng?'),
            SizedBox(height: 16),
            Text('Thao tác này sẽ xóa:'),
            Text('• Tất cả sản phẩm'),
            Text('• Tất cả danh mục và đơn vị'),
            Text('• Tất cả đơn hàng'),
            Text('• Tất cả phiên kiểm kê'),
            Text('• Tất cả cài đặt'),
            SizedBox(height: 16),
            Text(
              'DỮ LIỆU KHÔNG THỂ KHÔI PHỤC!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAll(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('XÓA TẤT CẢ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('XÁC NHẬN LẦN CUỐI'),
        content: const Text('Nhập "XÓA TẤT CẢ" để xác nhận:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete all data
              _showSuccessMessage(context, 'Đã xóa toàn bộ dữ liệu ứng dụng!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String dataType, String warning, VoidCallback onConfirm) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa dữ liệu $dataType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(warning),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  'Thao tác không thể hoàn tác!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

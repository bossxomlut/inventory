import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';

import '../../provider/theme.dart';
import '../../shared_widgets/index.dart';
import 'services/index.dart';

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
              color: Colors.white,
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
                  const SizedBox(height: 12),
                  _buildDeleteCard(
                    context,
                    icon: Icons.history,
                    title: 'Xóa lịch sử giao dịch',
                    description: 'Xóa toàn bộ lịch sử thay đổi sản phẩm',
                    dangerLevel: 'Cao',
                    onPressed: () => _deleteProductTransactions(context, ref),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.white,
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
      color: Colors.white,
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
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllProductsWithConfirmation(context);
  }

  void _deleteCategories(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllCategoriesWithConfirmation(context);
  }

  void _deleteUnits(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllUnitsWithConfirmation(context);
  }

  void _deleteOrders(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllOrdersWithConfirmation(context);
  }

  void _deleteCheckSessions(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllCheckSessionsWithConfirmation(context);
  }

  void _deleteProductTransactions(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllProductTransactionsWithConfirmation(context);
  }

  void _deleteAllData(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllDataWithConfirmation(context);
  }
}

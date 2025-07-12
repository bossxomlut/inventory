import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../provider/theme.dart';
import '../../shared_widgets/index.dart';

@RoutePage()
class ExportDataPage extends ConsumerWidget {
  const ExportDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Xuất dữ liệu',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedInformationCircle,
                          color: theme.colorPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thông tin',
                          style: theme.headingSemibold20Default,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Xuất dữ liệu ứng dụng ra file để backup hoặc chuyển sang thiết bị khác. Dữ liệu được xuất ra các định dạng:',
                      style: theme.textRegular14Default,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem('• JSON: Định dạng dễ đọc và xử lý'),
                    _buildInfoItem('• CSV: Định dạng Excel/Spreadsheet'),
                    _buildInfoItem('• Backup: File backup hoàn chỉnh'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildExportCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Xuất dữ liệu sản phẩm',
                    description: 'Xuất danh sách sản phẩm ra file JSON/CSV',
                    onExportJson: () => _exportProductsJson(context, ref),
                    onExportCsv: () => _exportProductsCsv(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    context,
                    icon: Icons.category,
                    title: 'Xuất dữ liệu danh mục',
                    description: 'Xuất danh sách danh mục ra file JSON/CSV',
                    onExportJson: () => _exportCategoriesJson(context, ref),
                    onExportCsv: () => _exportCategoriesCsv(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    context,
                    icon: Icons.straighten,
                    title: 'Xuất dữ liệu đơn vị',
                    description: 'Xuất danh sách đơn vị tính ra file JSON/CSV',
                    onExportJson: () => _exportUnitsJson(context, ref),
                    onExportCsv: () => _exportUnitsCsv(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Xuất dữ liệu đơn hàng',
                    description: 'Xuất danh sách đơn hàng ra file JSON/CSV',
                    onExportJson: () => _exportOrdersJson(context, ref),
                    onExportCsv: () => _exportOrdersCsv(context, ref),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: theme.colorSecondary.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.backup,
                            size: 48,
                            color: theme.colorPrimary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Backup toàn bộ dữ liệu',
                            style: theme.headingSemibold20Default,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tạo file backup chứa toàn bộ dữ liệu ứng dụng',
                            style: theme.textRegular14Default,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AppButton.primary(
                            title: 'Tạo file backup',
                            onPressed: () => _createFullBackup(context, ref),
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

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onExportJson,
    required VoidCallback onExportCsv,
  }) {
    final theme = context.appTheme;

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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onExportJson,
                    icon: const Icon(Icons.code),
                    label: const Text('Xuất JSON'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onExportCsv,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Xuất CSV'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportProductsJson(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'sản phẩm', 'JSON', () {
      // TODO: Implement export products to JSON
      _showSuccessMessage(context, 'Đã xuất dữ liệu sản phẩm ra file JSON!');
    });
  }

  void _exportProductsCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'sản phẩm', 'CSV', () {
      // TODO: Implement export products to CSV
      _showSuccessMessage(context, 'Đã xuất dữ liệu sản phẩm ra file CSV!');
    });
  }

  void _exportCategoriesJson(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'danh mục', 'JSON', () {
      // TODO: Implement export categories to JSON
      _showSuccessMessage(context, 'Đã xuất dữ liệu danh mục ra file JSON!');
    });
  }

  void _exportCategoriesCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'danh mục', 'CSV', () {
      // TODO: Implement export categories to CSV
      _showSuccessMessage(context, 'Đã xuất dữ liệu danh mục ra file CSV!');
    });
  }

  void _exportUnitsJson(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn vị tính', 'JSON', () {
      // TODO: Implement export units to JSON
      _showSuccessMessage(context, 'Đã xuất dữ liệu đơn vị tính ra file JSON!');
    });
  }

  void _exportUnitsCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn vị tính', 'CSV', () {
      // TODO: Implement export units to CSV
      _showSuccessMessage(context, 'Đã xuất dữ liệu đơn vị tính ra file CSV!');
    });
  }

  void _exportOrdersJson(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn hàng', 'JSON', () {
      // TODO: Implement export orders to JSON
      _showSuccessMessage(context, 'Đã xuất dữ liệu đơn hàng ra file JSON!');
    });
  }

  void _exportOrdersCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn hàng', 'CSV', () {
      // TODO: Implement export orders to CSV
      _showSuccessMessage(context, 'Đã xuất dữ liệu đơn hàng ra file CSV!');
    });
  }

  void _createFullBackup(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo file backup'),
        content: const Text('Bạn có chắc chắn muốn tạo file backup toàn bộ dữ liệu? File sẽ được lưu vào thư mục Downloads.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement create full backup
              _showSuccessMessage(context, 'Đã tạo file backup thành công!');
            },
            child: const Text('Tạo backup'),
          ),
        ],
      ),
    );
  }

  void _showExportConfirmation(BuildContext context, String dataType, String format, VoidCallback onConfirm) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xuất dữ liệu $dataType'),
        content: Text('Bạn có chắc chắn muốn xuất dữ liệu $dataType ra file $format?'),
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
            child: const Text('Xuất'),
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

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../provider/theme.dart';
import '../../shared_widgets/index.dart';
import 'services/data_export_service.dart';

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
                    _buildInfoItem('• JSONL: Định dạng JSON Lines, mỗi dòng là một object JSON'),
                    _buildInfoItem('• CSV: Định dạng Excel/Spreadsheet'),
                    _buildInfoItem('• Backup: File backup hoàn chỉnh định dạng JSON'),
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
                    description: 'Xuất danh sách sản phẩm ra file JSONL/CSV',
                    onExportJson: () => _exportProductsJsonl(context, ref),
                    onExportCsv: () => _exportProductsCsv(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    context,
                    icon: Icons.category,
                    title: 'Xuất dữ liệu danh mục',
                    description: 'Xuất danh sách danh mục ra file JSONL/CSV',
                    onExportJson: () => _exportCategoriesJsonl(context, ref),
                    onExportCsv: () => _exportCategoriesCsv(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    context,
                    icon: Icons.straighten,
                    title: 'Xuất dữ liệu đơn vị',
                    description: 'Xuất danh sách đơn vị tính ra file JSONL/CSV',
                    onExportJson: () => _exportUnitsJsonl(context, ref),
                    onExportCsv: () => _exportUnitsCsv(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Xuất dữ liệu đơn hàng',
                    description: 'Xuất danh sách đơn hàng ra file JSONL/CSV',
                    onExportJson: () => _exportOrdersJsonl(context, ref),
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
                  child:                  OutlinedButton.icon(
                    onPressed: onExportJson,
                    icon: const Icon(Icons.code),
                    label: const Text('Xuất JSONL'),
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

  // Products export methods
  void _exportProductsJsonl(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'sản phẩm', 'JSONL', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportProductsToJsonl();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu sản phẩm ra file JSONL!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  void _exportProductsCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'sản phẩm', 'CSV', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportProductsToCsv();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu sản phẩm ra file CSV!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  // Categories export methods
  void _exportCategoriesJsonl(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'danh mục', 'JSONL', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportCategoriesToJsonl();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu danh mục ra file JSONL!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  void _exportCategoriesCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'danh mục', 'CSV', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportCategoriesToCsv();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu danh mục ra file CSV!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  // Units export methods
  void _exportUnitsJsonl(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn vị tính', 'JSONL', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportUnitsToJsonl();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu đơn vị tính ra file JSONL!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  void _exportUnitsCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn vị tính', 'CSV', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportUnitsToCsv();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu đơn vị tính ra file CSV!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  // Orders export methods
  void _exportOrdersJsonl(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn hàng', 'JSONL', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportOrdersToJsonl();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu đơn hàng ra file JSONL!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  void _exportOrdersCsv(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'đơn hàng', 'CSV', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportOrdersToCsv();
        if (context.mounted) {
          _showSuccessMessage(context, 'Đã xuất dữ liệu đơn hàng ra file CSV!\nFile: ${filePath.split('/').last}');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  void _createFullBackup(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo file backup'),
        content: const Text('Bạn có chắc chắn muốn tạo file backup toàn bộ dữ liệu? File sẽ được lưu vào thư mục Documents.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final exportService = ref.read(dataExportServiceProvider);
                final filePath = await exportService.createFullBackup();
                if (context.mounted) {
                  _showSuccessMessage(context, 'Đã tạo file backup thành công!\nFile: ${filePath.split('/').last}');
                }
              } catch (e) {
                if (context.mounted) {
                  _showErrorMessage(context, 'Lỗi tạo backup: $e');
                }
              }
            },
            child: const Text('Tạo backup'),
          ),
        ],
      ),
    );
  }

  void _showExportConfirmation(BuildContext context, String dataType, String format, Future<void> Function() onConfirm) {
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
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:io';

import '../../provider/theme.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import 'services/data_export_service.dart';

@RoutePage()
class ExportDataPage extends ConsumerWidget {
  const ExportDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);

    return Scaffold(
      appBar: CustomAppBar(
        title: t(LKey.dataManagementExportTitle),
      ),
      body: SingleChildScrollView(
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
                          t(LKey.dataManagementExportInfoTitle),
                          style: theme.headingSemibold20Default,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(LKey.dataManagementExportInfoDescription),
                      style: theme.textRegular14Default,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(t(LKey.dataManagementExportInfoJsonl)),
                    _buildInfoItem(t(LKey.dataManagementExportInfoCsv)),
                    _buildInfoItem(t(LKey.dataManagementExportInfoBackup)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              t(LKey.dataManagementExportInfoTip),
                              style: theme.textRegular12Default.copyWith(
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Platform.isAndroid ? Colors.green.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Platform.isAndroid ? Colors.green.shade200 : Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            color: Platform.isAndroid ? Colors.green.shade700 : Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t(LKey.dataManagementExportInfoStorageTitle),
                                  style: theme.textMedium14Default.copyWith(
                                    color: Platform.isAndroid ? Colors.green.shade700 : Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  Platform.isAndroid
                                      ? t(LKey.dataManagementExportInfoStoragePathAndroid)
                                      : t(LKey.dataManagementExportInfoStoragePathIos),
                                  style: theme.textRegular12Sublest,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export Cards
            _buildExportCard(
              context,
              icon: Icons.inventory,
              title: t(LKey.dataManagementExportProductsTitle),
              description: t(LKey.dataManagementExportProductsDescription),
              onExportJson: () => _exportProductsJsonl(context, ref),
              onExportCsv: () => _exportProductsCsv(context, ref),
              onExportExcel: () => _exportProductsXlsx(context, ref),
            ),
            const SizedBox(height: 12),
            _buildExportCard(
              context,
              icon: Icons.category,
              title: t(LKey.dataManagementExportCategoriesTitle),
              description: t(LKey.dataManagementExportCategoriesDescription),
              onExportJson: () => _exportCategoriesJsonl(context, ref),
              onExportCsv: () => _exportCategoriesCsv(context, ref),
            ),
            const SizedBox(height: 12),
            _buildExportCard(
              context,
              icon: Icons.straighten,
              title: t(LKey.dataManagementExportUnitsTitle),
              description: t(LKey.dataManagementExportUnitsDescription),
              onExportJson: () => _exportUnitsJsonl(context, ref),
              onExportCsv: () => _exportUnitsCsv(context, ref),
            ),
            const SizedBox(height: 12),
            _buildExportCard(
              context,
              icon: Icons.shopping_cart,
              title: t(LKey.dataManagementExportOrdersTitle),
              description: t(LKey.dataManagementExportOrdersDescription),
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
                      t(LKey.dataManagementExportBackupTitle),
                      style: theme.headingSemibold20Default,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t(LKey.dataManagementExportBackupDescription),
                      style: theme.textRegular14Default,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppButton.primary(
                      title: t(LKey.dataManagementExportBackupButton),
                      onPressed: () => _createFullBackup(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Bottom padding
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
    VoidCallback? onExportExcel,
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
                    label: const Text('JSONL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onExportCsv,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('CSV'),
                  ),
                ),
                if (onExportExcel != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onExportExcel,
                      icon: const Icon(Icons.grid_on),
                      label: const Text('XLSX'),
                    ),
                  ),
                ],
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu sản phẩm ra file JSONL!', filePath);
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu sản phẩm ra file CSV!', filePath);
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'Lỗi xuất dữ liệu: $e');
        }
      }
    });
  }

  void _exportProductsXlsx(BuildContext context, WidgetRef ref) {
    _showExportConfirmation(context, 'sản phẩm', 'XLSX', () async {
      try {
        final exportService = ref.read(dataExportServiceProvider);
        final filePath = await exportService.exportProductsToXlsx();
        if (context.mounted) {
          _showSuccessMessageWithPath(
            context,
            ref,
            'Đã xuất dữ liệu sản phẩm ra file Excel!',
            filePath,
          );
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu danh mục ra file JSONL!', filePath);
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu danh mục ra file CSV!', filePath);
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu đơn vị tính ra file JSONL!', filePath);
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu đơn vị tính ra file CSV!', filePath);
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu đơn hàng ra file JSONL!', filePath);
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
          _showSuccessMessageWithPath(context, ref, 'Đã xuất dữ liệu đơn hàng ra file CSV!', filePath);
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
        content: const Text('Bạn có chắc chắn muốn tạo file backup toàn bộ dữ liệu?'),
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
                  _showSuccessMessageWithPath(context, ref, 'Đã tạo file backup thành công!', filePath);
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

  void _showSuccessMessageWithPath(BuildContext context, WidgetRef ref, String action, String filePath) {
    final fileName = filePath.split('/').last;
    String locationInfo;

    if (Platform.isAndroid) {
      if (filePath.contains('/storage/emulated/0/Documents/')) {
        // External Documents directory
        locationInfo = 'Vị trí: Documents/Đơn_và_kho_hàng/$fileName';
      } else if (filePath.contains('/storage/emulated/0/Android/data/')) {
        // External storage directory
        locationInfo = 'Vị trí: Android/data/[app]/files/Đơn_và_kho_hàng/$fileName';
      } else {
        // App documents directory
        locationInfo = 'Vị trí: Documents/[app]/$fileName';
      }
    } else {
      locationInfo = 'File: $fileName';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(locationInfo, style: const TextStyle(fontSize: 12)),
            if (Platform.isAndroid) ...[
              const SizedBox(height: 4),
              const Text(
                'Mở File Manager để xem file đã xuất',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Chia sẻ',
          textColor: Colors.white,
          onPressed: () async {
            try {
              await ref.read(dataExportServiceProvider).shareFile(filePath);
            } catch (e) {
              if (context.mounted) {
                _showErrorMessage(context, 'Không thể chia sẻ file: $e');
              }
            }
          },
        ),
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

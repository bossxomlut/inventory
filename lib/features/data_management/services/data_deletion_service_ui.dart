import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../provider/theme.dart';
import '../../../shared_widgets/data_import_result_dialog.dart';
import '../../../shared_widgets/dialog.dart';
import '../../../shared_widgets/error_details_dialog.dart';
import 'data_deletion_service.dart';
import 'data_import_service.dart';

/// Confirmation dialog for deletion operations
class DeletionConfirmationDialog extends StatelessWidget with ShowDialog<bool> {
  const DeletionConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.isDestructive = true,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  @override
  String? get routeName => 'DeletionConfirmationDialog';

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.headingSemibold20Default.copyWith(
                      color: isDestructive ? Colors.red[700] : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: theme.textRegular14Default,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[300]),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      cancelText,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                Container(width: 1, height: 48, color: Colors.grey[300]),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: isDestructive ? Colors.red : theme.colorPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress dialog for deletion operations
class DeletionProgressDialog extends StatelessWidget with ShowDialog<void> {
  const DeletionProgressDialog({
    super.key,
    required this.message,
  });

  final String message;

  @override
  String? get routeName => 'DeletionProgressDialog';

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textRegular14Default,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// UI extension for DataDeletionService to provide confirmation dialogs and result display
extension DataDeletionServiceUI on DataDeletionService {
  /// Show confirmation dialog and delete all products
  Future<void> deleteAllProductsWithConfirmation(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Xác nhận xóa sản phẩm',
      message: 'Bạn có chắc chắn muốn xóa TẤT CẢ sản phẩm? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa tất cả',
      cancelText: 'Hủy',
    );

    if (confirmed && context.mounted) {
      await _performDeletionWithProgress(
        context,
        () => deleteAllProducts(),
        'Đang xóa sản phẩm...',
      );
    }
  }

  /// Show confirmation dialog and delete all categories
  Future<void> deleteAllCategoriesWithConfirmation(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Xác nhận xóa danh mục',
      message: 'Bạn có chắc chắn muốn xóa TẤT CẢ danh mục? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa tất cả',
      cancelText: 'Hủy',
    );

    if (confirmed && context.mounted) {
      await _performDeletionWithProgress(
        context,
        () => deleteAllCategories(),
        'Đang xóa danh mục...',
      );
    }
  }

  /// Show confirmation dialog and delete all units
  Future<void> deleteAllUnitsWithConfirmation(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Xác nhận xóa đơn vị',
      message: 'Bạn có chắc chắn muốn xóa TẤT CẢ đơn vị? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa tất cả',
      cancelText: 'Hủy',
    );

    if (confirmed && context.mounted) {
      await _performDeletionWithProgress(
        context,
        () => deleteAllUnits(),
        'Đang xóa đơn vị...',
      );
    }
  }

  /// Show confirmation dialog and delete all data
  Future<void> deleteAllDataWithConfirmation(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Xác nhận xóa toàn bộ dữ liệu',
      message: 'Bạn có chắc chắn muốn xóa TOÀN BỘ dữ liệu (sản phẩm, danh mục và đơn vị)?\n\nHành động này không thể hoàn tác và sẽ xóa toàn bộ dữ liệu trong ứng dụng.',
      confirmText: 'Xóa toàn bộ',
      cancelText: 'Hủy',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await _performDeletionWithProgress(
        context,
        () => deleteAllData(),
        'Đang xóa tất cả dữ liệu...',
      );
    }
  }

  /// Show confirmation dialog
  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    bool isDestructive = true,
  }) async {
    final dialog = DeletionConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
    );

    final result = await dialog.show(context, barrierDismissible: false);
    return result ?? false;
  }

  /// Perform deletion with progress indicator and show result
  Future<void> _performDeletionWithProgress(
    BuildContext context,
    Future<DataDeletionResult> Function() deletionFunction,
    String progressMessage,
  ) async {
    // Show progress dialog
    final progressDialog = DeletionProgressDialog(message: progressMessage);
    progressDialog.show(context, barrierDismissible: false);

    try {
      // Perform deletion
      final result = await deletionFunction();

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show result
      if (context.mounted) {
        await _showDeletionResult(context, result);
      }
    } catch (e) {
      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        await _showDeletionResult(
          context,
          DataDeletionResult(
            success: false,
            totalItems: 0,
            deletedCount: 0,
            failedCount: 0,
            errors: ['Lỗi không mong muốn: $e'],
            message: 'Lỗi khi thực hiện xóa dữ liệu',
          ),
        );
      }
    }
  }

  /// Show deletion result dialog
  Future<void> _showDeletionResult(BuildContext context, DataDeletionResult result) async {
    if (result.hasErrors && result.errors.length > 3) {
      // Show detailed errors if there are many
      final errorDetails = result.errors.join('\n• ');
      final errorDialog = ErrorDetailsDialog(
        title: result.success ? 'Xóa hoàn thành với lỗi' : 'Lỗi khi xóa dữ liệu',
        message: result.message,
        details: '• $errorDetails',
      );
      await errorDialog.show(context);
    } else {
      // Show simple result dialog using DataImportResultDialog
      // Convert DataDeletionResult to DataImportResult
      final importResult = _convertToDataImportResult(result);

      final resultDialog = DataImportResultDialog(
        result: importResult,
        title: result.success ? 'Xóa dữ liệu thành công' : 'Lỗi khi xóa dữ liệu',
      );
      await resultDialog.show(context);
    }
  }

  /// Convert DataDeletionResult to DataImportResult for dialog compatibility
  DataImportResult _convertToDataImportResult(DataDeletionResult result) {
    return DataImportResult(
      success: result.success,
      totalLines: result.totalItems,
      successfulImports: result.deletedCount,
      errors: result.errors,
    );
  }
}

/// Provider for DataDeletionService
final dataDeletionServiceProvider = Provider<DataDeletionService>((ref) {
  return DataDeletionService(ref: ref);
});

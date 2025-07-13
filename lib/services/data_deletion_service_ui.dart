import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/data_management/services/data_import_service.dart';
import '../shared_widgets/data_import_result_dialog.dart';
import '../shared_widgets/error_details_dialog.dart';
import 'data_deletion_service.dart';

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
      message:
          'Bạn có chắc chắn muốn xóa TOÀN BỘ dữ liệu (sản phẩm, danh mục và đơn vị)?\n\nHành động này không thể hoàn tác và sẽ xóa toàn bộ dữ liệu trong ứng dụng.',
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
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDestructive ? Colors.red[700] : Colors.black87,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  cancelText,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? Colors.red : Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Perform deletion with progress indicator and show result
  Future<void> _performDeletionWithProgress(
    BuildContext context,
    Future<DataDeletionResult> Function() deletionFunction,
    String progressMessage,
  ) async {
    // Show progress dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(progressMessage),
          ],
        ),
      ),
    );

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
      await showDialog<void>(
        context: context,
        builder: (context) => ErrorDetailsDialog(
          title: result.success ? 'Xóa hoàn thành với lỗi' : 'Lỗi khi xóa dữ liệu',
          message: result.message,
          details: '• $errorDetails',
        ),
      );
    } else {
      // Show simple result dialog using DataImportResultDialog
      // Convert DataDeletionResult to DataImportResult
      final importResult = _convertToDataImportResult(result);

      await showDialog<void>(
        context: context,
        builder: (context) => DataImportResultDialog(
          result: importResult,
          title: result.success ? 'Xóa dữ liệu thành công' : 'Lỗi khi xóa dữ liệu',
        ),
      );
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

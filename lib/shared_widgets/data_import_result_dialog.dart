import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../provider/theme.dart';
import '../resources/theme.dart';
import '../services/data_import_service.dart';

/// Widget để hiển thị kết quả nhập dữ liệu một cách trực quan và chi tiết
class DataImportResultDialog extends StatelessWidget {
  final DataImportResult result;
  final String title;

  const DataImportResultDialog({
    super.key,
    required this.result,
    this.title = 'Kết quả nhập dữ liệu',
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getHeaderColor(theme),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.headingSemibold20Default.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getStatusText(),
                          style: theme.textRegular14Default.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Statistics
                    _buildSummarySection(theme),

                    if (result.hasErrors) ...[
                      const SizedBox(height: 24),
                      _buildErrorSection(theme),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (result.hasPartialSuccess)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Có thể thêm logic để retry chỉ những items lỗi
                        },
                        icon: Icon(
                          HugeIcons.strokeRoundedRefresh,
                          color: theme.colorPrimary,
                        ),
                        label: Text(
                          'Thử lại',
                          style: TextStyle(
                            color: theme.colorPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorPrimary,
                          side: BorderSide(color: theme.colorPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                  if (result.hasPartialSuccess) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        HugeIcons.strokeRoundedCheckmarkCircle02,
                        color: Colors.white,
                      ),
                      label: Text(
                        result.success ? 'Hoàn thành' : 'Đóng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: result.success ? theme.colorTextSupportGreen : theme.colorPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

  Widget _buildSummarySection(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorBorderSublest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: theme.headingSemibold20Default,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Tổng số dòng',
                  result.totalLines.toString(),
                  HugeIcons.strokeRoundedFile02,
                  theme.colorTextSubtle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Thành công',
                  result.successfulImports.toString(),
                  HugeIcons.strokeRoundedCheckmarkCircle02,
                  theme.colorTextSupportGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Thất bại',
                  result.failedImports.toString(),
                  HugeIcons.strokeRoundedCancelCircle,
                  theme.colorError,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Tỷ lệ thành công',
                  '${(result.successfulImports / result.totalLines * 100).toStringAsFixed(1)}%',
                  HugeIcons.strokeRoundedChartLineData02,
                  result.success ? theme.colorTextSupportGreen : theme.colorTextSupportRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(AppThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.headingSemibold20Default.copyWith(color: color),
          ),
          Text(
            label,
            style: theme.textRegular12Default.copyWith(
              color: theme.colorTextSubtle,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorError.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorError.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedAlert02,
                color: theme.colorError,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Chi tiết lỗi (${result.errors.length})',
                style: theme.headingSemibold20Default.copyWith(
                  color: theme.colorError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                children: result.errors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final error = entry.value;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorError.withOpacity(0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorError,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: theme.buttonSemibold12.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            error,
                            style: theme.textRegular14Default,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeaderColor(AppThemeData theme) {
    if (result.success) {
      return theme.colorTextSupportGreen;
    } else if (result.hasPartialSuccess) {
      return theme.colorTextSupportBlue;
    } else {
      return theme.colorError;
    }
  }

  IconData _getStatusIcon() {
    if (result.success) {
      return HugeIcons.strokeRoundedCheckmarkCircle02;
    } else if (result.hasPartialSuccess) {
      return HugeIcons.strokeRoundedAlert02;
    } else {
      return HugeIcons.strokeRoundedCancelCircle;
    }
  }

  String _getStatusText() {
    if (result.success) {
      return 'Tất cả dữ liệu đã được nhập thành công';
    } else if (result.hasPartialSuccess) {
      return 'Một số dữ liệu đã được nhập thành công';
    } else {
      return 'Không có dữ liệu nào được nhập thành công';
    }
  }

  /// Static method để hiển thị dialog
  static Future<void> show(
    BuildContext context,
    DataImportResult result, {
    String? title,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataImportResultDialog(
        result: result,
        title: title ?? 'Kết quả nhập dữ liệu',
      ),
    );
  }
}

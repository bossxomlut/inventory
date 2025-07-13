import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../provider/theme.dart';
import '../resources/theme.dart';
import '../services/data_import_service.dart';
import 'dialog.dart';

/// Widget để hiển thị kết quả validation dữ liệu trước khi nhập
class DataValidationResultDialog extends StatelessWidget with ShowDialog<bool> {
  final ValidationResult result;
  final String title;
  final VoidCallback? onProceedImport;
  final bool barrierDismissible;

  const DataValidationResultDialog({
    super.key,
    required this.result,
    this.title = 'Kiểm tra dữ liệu',
    this.onProceedImport,
    this.barrierDismissible = false, // Không cho phép tap outside khi đang validation
  });

  @override
  String? get routeName => 'DataValidationResultDialog';

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.zero,
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
                    onPressed: () => Navigator.of(context).pop(false),
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
              child: Scrollbar(
                thumbVisibility: true, // Always show scrollbar thumb
                trackVisibility: true, // Show scrollbar track
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Statistics
                      _buildSummarySection(theme),

                      if (result.errors.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildErrorSection(theme),
                      ],

                      if (result.hasWarnings) ...[
                        const SizedBox(height: 24),
                        _buildWarningSection(theme),
                      ],
                    ],
                  ),
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
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(
                        HugeIcons.strokeRoundedCancelCircle,
                        color: theme.colorTextSubtle,
                      ),
                      label: Text(
                        'Hủy',
                        style: TextStyle(
                          color: theme.colorTextSubtle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorTextSubtle,
                        side: BorderSide(color: theme.colorTextSubtle),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: result.isValid
                          ? () {
                              Navigator.of(context).pop(true);
                              onProceedImport?.call();
                            }
                          : null,
                      icon: Icon(
                        result.isValid ? HugeIcons.strokeRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedAlert02,
                        color: Colors.white,
                      ),
                      label: Text(
                        result.isValid ? 'Tiếp tục nhập' : 'Có lỗi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: result.isValid ? theme.colorTextSupportGreen : theme.colorError,
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
            'Thống kê kiểm tra',
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
                  'Dòng hợp lệ',
                  result.validLines.toString(),
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
                  'Lỗi',
                  result.errors.length.toString(),
                  HugeIcons.strokeRoundedCancelCircle,
                  theme.colorError,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Cảnh báo',
                  result.warnings.length.toString(),
                  HugeIcons.strokeRoundedAlert02,
                  theme.colorTextSupportBlue,
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
    return _buildIssueSection(
      theme,
      'Lỗi cần sửa',
      result.errors,
      theme.colorError,
      HugeIcons.strokeRoundedAlert02,
    );
  }

  Widget _buildWarningSection(AppThemeData theme) {
    return _buildIssueSection(
      theme,
      'Cảnh báo',
      result.warnings,
      theme.colorTextSupportBlue,
      HugeIcons.strokeRoundedInformationCircle,
    );
  }

  Widget _buildIssueSection(AppThemeData theme, String title, List<String> issues, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$title (${issues.length})',
                style: theme.headingSemibold20Default.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: Scrollbar(
              thumbVisibility: true, // Always show scrollbar thumb
              trackVisibility: true, // Show scrollbar track
              child: SingleChildScrollView(
                child: Column(
                  children: issues.asMap().entries.map((entry) {
                    final index = entry.key;
                    final issue = entry.value;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
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
                              issue,
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
          ),
        ],
      ),
    );
  }

  Color _getHeaderColor(AppThemeData theme) {
    if (result.isValid && !result.hasWarnings) {
      return theme.colorTextSupportGreen;
    } else if (result.isValid && result.hasWarnings) {
      return theme.colorTextSupportBlue;
    } else {
      return theme.colorError;
    }
  }

  IconData _getStatusIcon() {
    if (result.isValid && !result.hasWarnings) {
      return HugeIcons.strokeRoundedCheckmarkCircle02;
    } else if (result.isValid && result.hasWarnings) {
      return HugeIcons.strokeRoundedAlert02;
    } else {
      return HugeIcons.strokeRoundedCancelCircle;
    }
  }

  String _getStatusText() {
    if (result.isValid && !result.hasWarnings) {
      return 'Dữ liệu hợp lệ, sẵn sàng nhập';
    } else if (result.isValid && result.hasWarnings) {
      return 'Dữ liệu hợp lệ nhưng có cảnh báo';
    } else {
      return 'Dữ liệu có lỗi cần sửa';
    }
  }

  /// Static method để hiển thị dialog sử dụng ShowDialog mixin
  static Future<bool> showValidation(
    BuildContext context,
    ValidationResult result, {
    String? title,
    VoidCallback? onProceedImport,
    bool barrierDismissible = false,
  }) async {
    final result_ = await DataValidationResultDialog(
      result: result,
      title: title ?? 'Kiểm tra dữ liệu',
      onProceedImport: onProceedImport,
      barrierDismissible: barrierDismissible,
    ).show(context, barrierDismissible: barrierDismissible);
    return result_ ?? false;
  }

  /// Hiển thị dialog với các tùy chọn của ShowDialog mixin
  Future<bool?> showWithOptions(BuildContext context, {bool? dismissible}) {
    return show(
      context,
      barrierDismissible: dismissible ?? barrierDismissible,
    );
  }
}

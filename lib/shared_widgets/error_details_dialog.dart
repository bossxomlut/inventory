import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../provider/theme.dart';
import 'dialog.dart';

/// Dialog để hiển thị lỗi chi tiết với giao diện đẹp
class ErrorDetailsDialog extends StatelessWidget with ShowDialog<void> {
  final String title;
  final String message;
  final String? details;
  final String? buttonText;
  final bool barrierDismissible;

  const ErrorDetailsDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.buttonText,
    this.barrierDismissible = false, // Mặc định không cho phép tap outside để đóng
  });

  @override
  String? get routeName => 'ErrorDetailsDialog';

  /// Hiển thị dialog với các tùy chọn của ShowDialog mixin
  Future<void> showErrorDialog(BuildContext context, {bool? dismissible}) {
    return show(
      context,
      barrierDismissible: dismissible ?? barrierDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      insetPadding: EdgeInsets.zero,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 480,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với màu đỏ cho lỗi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorError,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    HugeIcons.strokeRoundedAlert02,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.headingSemibold20Default.copyWith(
                        color: Colors.white,
                      ),
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
              child: Scrollbar(
                thumbVisibility: true, // Always show scrollbar thumb
                trackVisibility: true, // Show scrollbar track
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main error message
                      Text(
                        message,
                        style: theme.textMedium16Default,
                      ),

                      // Error details if provided
                      if (details != null && details!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorError.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorError.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chi tiết lỗi:',
                                style: theme.textMedium14Default.copyWith(
                                  color: theme.colorError,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                details!,
                                style: theme.textRegular14Default.copyWith(
                                  color: theme.colorTextSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorError,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText ?? 'Đóng',
                  style: theme.textMedium16Default.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog lỗi với thông tin chi tiết (static method for convenience)
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? details,
    String? buttonText,
    bool barrierDismissible = false,
  }) {
    return ErrorDetailsDialog(
      title: title,
      message: message,
      details: details,
      buttonText: buttonText,
      barrierDismissible: barrierDismissible,
    ).show(context, barrierDismissible: barrierDismissible);
  }
}

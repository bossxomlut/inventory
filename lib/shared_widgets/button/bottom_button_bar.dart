import 'package:flutter/material.dart';

import '../index.dart';

//create a bottom button bar with 2 buttons
class BottomButtonBar extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  //padding for button
  final EdgeInsetsGeometry padding;
  final String? saveButtonText;
  final String? cancelButtonText;
  final bool isListenKeyboardVisibility;
  final bool showSaveButton;
  final bool showCancelButton;

  const BottomButtonBar({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.saveButtonText,
    this.cancelButtonText,
    this.isListenKeyboardVisibility = false,
    this.showSaveButton = true,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showSaveButton && !showCancelButton) {
      return const SizedBox.shrink();
    }
    return KeyboardVisibilityBuilder(
      isDisable: !isListenKeyboardVisibility,
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: padding,
          child: SafeArea(
            child: Row(
              children: [
                if (showCancelButton)
                  Expanded(
                    child: AppButton.secondary(
                      title: cancelButtonText ?? 'Huỷ',
                      onPressed: onCancel,
                    ),
                  ),
                if (showCancelButton && showSaveButton) const Gap(8),
                if (showSaveButton)
                  Expanded(
                    child: AppButton.primary(
                      title: saveButtonText ?? 'Lưu',
                      onPressed: onSave,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

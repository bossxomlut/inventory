import 'package:flutter/material.dart';

import '../index.dart';

//create a bottom button bar with 2 buttons
class BottomButtonBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  //padding for button
  final EdgeInsetsGeometry padding;
  final String? saveButtonText;
  final String? cancelButtonText;

  const BottomButtonBar({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.saveButtonText,
    this.cancelButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      child: Padding(
        padding: padding,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                  child: AppButton.secondary(
                title: cancelButtonText ?? 'Huỷ',
                onPressed: onCancel,
              )),
              const Gap(8),
              Expanded(
                  child: AppButton.primary(
                title: saveButtonText ?? 'Lưu',
                onPressed: onSave,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

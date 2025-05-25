import 'package:flutter/material.dart';

import '../index.dart';

//create a bottom button bar with 2 buttons
class BottomButtonBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  //padding for button
  final EdgeInsetsGeometry padding;

  const BottomButtonBar({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(child: AppButton.secondary(title: 'Cancel', onPressed: onCancel)),
            const Gap(8),
            Expanded(child: AppButton.primary(title: 'Save', onPressed: onSave)),
          ],
        ),
      ),
    );
  }
}

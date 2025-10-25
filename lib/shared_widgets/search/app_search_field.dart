import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../provider/index.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.margin,
    this.padding,
    this.textInputAction = TextInputAction.search,
    this.keyDetectorKey = 'text-field-detector',
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final TextInputAction textInputAction;
  final String keyDetectorKey;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    Widget buildField(TextEditingValue value) {
      final hasText = value.text.isNotEmpty;
      return TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                    onClear?.call();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorBorderField),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorBorderField),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorPrimary),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
    }

    return VisibilityDetector(
      key: Key(keyDetectorKey),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0 && (focusNode?.hasFocus ?? true)) {
          FocusScope.of(context).unfocus(); // 🔥 ẩn bàn phím
        }
      },
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return Padding(
              padding: padding ?? EdgeInsets.zero,
              child: buildField(value),
            );
          },
        ),
      ),
    );


  }
}

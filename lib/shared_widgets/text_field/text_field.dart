import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../provider/theme.dart';

// Custom TextField Widget for Reuse
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isRequired;
  final VoidCallback? onTap;
  final ValueChanged<String> onChanged;
  final bool hideText;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isReadOnly;
  final bool isDisable;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.hideText = false,
    this.onTap,
    required this.onChanged,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.isReadOnly = false,
    this.isDisable = false,
    this.textInputAction,
    this.onSubmitted,
    this.minLines,
    this.maxLines,
    this.maxLength,
  }) : super(key: key);

  factory CustomTextField.password({
    required String label,
    TextEditingController? controller,
    bool isRequired = false,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    Key? key,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    String? initialValue,
  }) {
    return CustomTextField(
      key: key,
      label: label,
      initialValue: initialValue,
      controller: controller,
      isRequired: isRequired,
      onChanged: onChanged,
      hideText: true,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      maxLines: 1,
    );
  }

  factory CustomTextField.search({
    required String hint,
    TextEditingController? controller,
    bool isRequired = false,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    Key? key,
  }) {
    return CustomTextField(
      key: key,
      hint: hint,
      controller: controller,
      isRequired: isRequired,
      onChanged: onChanged,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.search),
    );
  }

  factory CustomTextField.multiLines({
    Key? key,
    String? label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    FocusNode? focusNode,
    Widget? prefixIcon,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    int minLines = 3,
    int? maxLines,
    int? maxLength,
  }) {
    return CustomTextField(
      key: key,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      onChanged: (String value) {},
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool showText = true;

  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    } else {
      _controller = widget.controller!;
    }

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
    } else {
      _focusNode = widget.focusNode!;
    }

    if (widget.hideText) {
      _focusNode.addListener(_handleFocusChange);
    }

    showText = !widget.hideText;
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        showText = false;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }

    _focusNode.removeListener(_handleFocusChange);

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      constraints: const BoxConstraints(
        minHeight: 54.0,
        // maxHeight: 120.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0), // Bo góc
        border: Border.all(color: theme.colorBorderField),
        color: widget.isDisable ? theme.colorBackgroundFieldDisable : theme.colorBackgroundField,
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0), // Bo góc
        child: TextFormField(
          focusNode: _focusNode,
          controller: _controller,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          style: theme.textMedium15Default, // Màu
          cursorColor: theme.colorPrimary,
          selectionControls: materialTextSelectionControls, // Dùng Selection Control mặc định
          selectionHeightStyle: BoxHeightStyle.tight,
          selectionWidthStyle: BoxWidthStyle.tight,
          obscureText: !showText,
          obscuringCharacter: '*',
          readOnly: widget.isReadOnly || widget.isDisable,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            labelText: widget.isRequired ? '${widget.label}*' : widget.label, // Hiển thị dấu * nếu bắt buộc
            labelStyle: theme.textRegular15Sublest, // Màu label
            hintStyle: theme.textMedium15Sublest,
            hintText: widget.hint,
            // filled: true,
            // fillColor: widget.isDisable ? theme.colorBackgroundFieldDisable : theme.colorBackgroundField,
            border: InputBorder.none,
            focusColor: theme.colorPrimary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            prefixIcon: widget.prefixIcon,
            prefixIconColor: theme.colorTextSublest,
            suffixIcon: widget.hideText
                ? ExcludeFocus(
                    child: Builder(builder: (context) {
                      return showText
                          ? IconButton(
                              icon: Icon(
                                LineIcons.eye,
                                color: theme.colorIcon,
                              ),
                              onPressed: () {
                                setState(() {
                                  showText = !showText;
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                LineIcons.eyeSlash,
                                color: theme.colorIcon,
                              ),
                              onPressed: () {
                                setState(() {
                                  showText = !showText;
                                });
                              },
                            );
                    }),
                  )
                : widget.suffixIcon,
          ),

          // enabled: !(widget.isReadOnly || widget.isDisable),
          // inputFormatters: [
          //   //prevent space
          //   FilteringTextInputFormatter.deny(RegExp(r'\s')),
          // ],
        ),
      ),
    );
  }
}

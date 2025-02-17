import 'dart:ui';

import 'package:flutter/material.dart';

import '../../resource/index.dart';

// Custom TextField Widget for Reuse
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isRequired;
  final ValueChanged<String> onChanged;
  final bool hideText;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final bool isReadOnly;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.hideText = false,
    required this.onChanged,
    this.focusNode,
    this.prefixIcon,
    this.isReadOnly = false,
  }) : super(key: key);

  factory CustomTextField.password({
    required String label,
    TextEditingController? controller,
    bool isRequired = false,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    Key? key,
  }) {
    return CustomTextField(
      key: key,
      label: label,
      controller: controller,
      isRequired: isRequired,
      onChanged: onChanged,
      hideText: true,
      focusNode: focusNode,
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
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0), // Bo góc
        border: Border.all(color: theme.borderColor),
        color: theme.canvasColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0), // Bo góc
        child: TextFormField(
          focusNode: _focusNode,
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          // style: theme.textMedium15Default, // Màu
          // cursorColor: theme.colorPrimary,
          selectionControls: materialTextSelectionControls, // Dùng Selection Control mặc định
          selectionHeightStyle: BoxHeightStyle.tight,
          selectionWidthStyle: BoxWidthStyle.tight,
          obscureText: !showText,
          obscuringCharacter: '*',
          readOnly: widget.isReadOnly,
          decoration: InputDecoration(
            labelText: widget.isRequired ? '${widget.label}*' : widget.label, // Hiển thị dấu * nếu bắt buộc
            // labelStyle: theme.textRegular15Sublest, // Màu label
            // hintStyle: theme.textMedium15Sublest,
            hintText: widget.hint,
            // filled: true,
            // fillColor: Color(0x0DFFFFFF),
            border: InputBorder.none,
            // focusColor: theme.colorPrimary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9),
            prefixIcon: widget.prefixIcon,
            // prefixIconColor: theme.colorTextSublest,
            suffixIcon: widget.hideText
                ? AnimatedBuilder(
                    animation: _focusNode,
                    builder: (context, child) {
                      return showText
                          ? IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {
                                setState(() {
                                  showText = !showText;
                                });
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.remove_red_eye_outlined),
                              onPressed: () {
                                setState(() {
                                  showText = !showText;
                                });
                              },
                            );
                    })
                : null,
          ),
          // inputFormatters: [
          //   //prevent space
          //   FilteringTextInputFormatter.deny(RegExp(r'\s')),
          // ],
        ),
      ),
    );
  }
}

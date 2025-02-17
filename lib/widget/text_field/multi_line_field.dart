import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

// Custom TextField Widget for Reuse
class MultiLineField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isRequired;
  final ValueChanged<String> onChanged;
  final bool hideText;
  final FocusNode? focusNode;
  final int line;
  final String? initialValue;

  const MultiLineField({
    Key? key,
    required this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.hideText = false,
    required this.onChanged,
    this.focusNode,
    this.initialValue,
    this.line = 3,
  }) : super(key: key);

  factory MultiLineField.password({
    required String label,
    TextEditingController? controller,
    bool isRequired = false,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    Key? key,
  }) {
    return MultiLineField(
      key: key,
      label: label,
      controller: controller,
      isRequired: isRequired,
      onChanged: onChanged,
      hideText: true,
      focusNode: focusNode,
    );
  }

  @override
  State<MultiLineField> createState() => _MultiLineFieldState();
}

class _MultiLineFieldState extends State<MultiLineField> {
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
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0), // Bo góc
            // border: Border.all(color: theme.colorScheme),
            // color: theme.colorBackgroundField, // Viền field
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0), // Bo góc
            child: TextFormField(
              minLines: widget.line,
              maxLines: 99,
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
              decoration: InputDecoration(
                labelText: widget.isRequired ? '${widget.label}*' : widget.label, // Hiển thị dấu * nếu bắt buộc
                // labelStyle: theme.textRegular15Sublest, // Màu label
                // hintStyle: theme.textMedium15Sublest,
                alignLabelWithHint: true,
                // filled: true,
                // fillColor: Color(0x0DFFFFFF),
                border: InputBorder.none,
                // focusColor: theme.colorPrimary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9),
                suffixIcon: widget.hideText
                    ? AnimatedBuilder(
                        animation: _focusNode,
                        builder: (context, child) {
                          return showText
                              ? IconButton(
                                  icon: Icon(LineIcons.eye),
                                  onPressed: () {
                                    setState(() {
                                      showText = !showText;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(LineIcons.eyeSlash),
                                  onPressed: () {
                                    setState(() {
                                      showText = !showText;
                                    });
                                  },
                                );
                        })
                    : null,
              ),
            ),
          ),
        ),
        const Positioned(bottom: 0, right: 0, child: Icon(LineIcons.dragon)),
      ],
    );
  }
}

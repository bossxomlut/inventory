import 'package:flutter/material.dart';

import '../provider/index.dart';

class AppFilterChip extends StatelessWidget {
  final Widget label;
  final Widget? avatar;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final bool showDeleteIcon;
  final Widget? deleteIcon;
  final VisualDensity? visualDensity;

  const AppFilterChip({
    super.key,
    required this.label,
    this.avatar,
    this.onDeleted,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.showDeleteIcon = true,
    this.deleteIcon,
    this.visualDensity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Chip(
      label: label,
      avatar: avatar,
      backgroundColor: backgroundColor ?? theme.colorBackgroundSurface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: borderColor ?? theme.colorBorderField,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: visualDensity ?? VisualDensity.compact,
      deleteIcon: showDeleteIcon ? (deleteIcon ?? const Icon(Icons.close, size: 16)) : null,
      onDeleted: showDeleteIcon ? onDeleted : null,
    );
  }
}

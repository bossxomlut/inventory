import 'package:flutter/material.dart';

import '../../provider/theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.type,
    required this.title,
    required this.onPressed,
    required this.size,
    this.child,
    this.padding,
  });
  factory AppButton.primary({
    Key? key,
    required String title,
    VoidCallback? onPressed,
    Widget? child,
    EdgeInsets? padding,
    ButtonSize size = ButtonSize.medium,
  }) {
    return AppButton(
      key: key,
      type: ButtonType.primary,
      size: size,
      title: title,
      padding: padding,
      onPressed: onPressed,
      child: child,
    );
  }

  factory AppButton.ghost({
    Key? key,
    required String title,
    Widget? child,
    EdgeInsets? padding,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
  }) {
    return AppButton(
      key: key,
      type: ButtonType.ghost,
      size: size,
      title: title,
      padding: padding,
      onPressed: onPressed,
      child: child,
    );
  }

  factory AppButton.secondary({
    Key? key,
    required String title,
    Widget? child,
    EdgeInsets? padding,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
  }) {
    return AppButton(
      key: key,
      type: ButtonType.secondary,
      size: size,
      title: title,
      padding: padding,
      onPressed: onPressed,
      child: child,
    );
  }

  factory AppButton.tertiary({
    Key? key,
    required String title,
    Widget? child,
    EdgeInsets? padding,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
  }) {
    return AppButton(
      key: key,
      type: ButtonType.tertiary,
      size: size,
      title: title,
      padding: padding,
      onPressed: onPressed,
      child: child,
    );
  }

  final ButtonType type;
  final ButtonSize size;
  final String title;
  final Widget? child;
  final EdgeInsets? padding;

  ///[onPressed] is a callback function that will be called when the button is pressed.
  ///if [onPressed] is null, the button will be disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final theme = context.appTheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: type.getShape(context, isDisabled),
        backgroundColor: type.getBackGroundColor(context),
        overlayColor: MaterialStateColor.resolveWith((states) {
          switch (type) {
            case ButtonType.primary:
              return theme.colorSecondary;
            default:
              return theme.colorPrimary;
          }
        }),
        disabledBackgroundColor: type.getDisableBackGroundColor(context),
        fixedSize: Size.fromHeight(size.getHeight()),
        padding: padding,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child ??
            Text(
              title,
              style: type.getTextStyle(context, size, isDisabled),
            ),
      ),
    );
  }
}

enum ButtonType { primary, secondary, tertiary, ghost }

extension ButtonTypeX on ButtonType {
  Color getBackGroundColor(BuildContext context) {
    switch (this) {
      case ButtonType.primary:
        return context.appTheme.colorPrimary;
      case ButtonType.secondary:
        return context.appTheme.colorSecondary;
      case ButtonType.tertiary:
        return context.appTheme.colorTransparent;
      case ButtonType.ghost:
        return context.appTheme.colorGhost;
    }
  }

  Color getDisableBackGroundColor(BuildContext context) {
    switch (this) {
      case ButtonType.primary:
        return context.appTheme.colorPrimaryDisable;
      case ButtonType.secondary:
        return context.appTheme.colorPrimaryDisable.withOpacity(0.05);
      case ButtonType.tertiary:
        return context.appTheme.colorTransparent;
      case ButtonType.ghost:
        return context.appTheme.colorTransparent;
    }
  }

  Color getTextColor(BuildContext context, bool isDisabled) {
    switch (isDisabled) {
      case true:
        switch (this) {
          case ButtonType.primary:
            return context.appTheme.colorTextDisable;
          case ButtonType.secondary:
            return context.appTheme.colorTextSublest;
          case ButtonType.tertiary:
            return context.appTheme.colorTextDisable;
          case ButtonType.ghost:
            return context.appTheme.colorTextDisable;
        }
      case false:
        switch (this) {
          case ButtonType.primary:
            return context.appTheme.colorTextWhite;
          case ButtonType.secondary:
            return context.appTheme.colorTextPrimary;
          case ButtonType.tertiary:
            return context.appTheme.colorTextPrimary;
          case ButtonType.ghost:
            return context.appTheme.colorTextPrimary;
        }
    }
  }

  OutlinedBorder? getShape(BuildContext context, bool isDisabled) {
    switch (this) {
      case ButtonType.primary:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        );
      case ButtonType.secondary:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        );
      case ButtonType.tertiary:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isDisabled ? context.appTheme.colorDisabled : context.appTheme.colorPrimary,
          ),
        );
      case ButtonType.ghost:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        );
    }
  }

  TextStyle getTextStyle(BuildContext context, ButtonSize size, bool isDisabled) {
    final baseStyle = size.getTextStyle(context);
    return baseStyle.copyWith(
      color: getTextColor(context, isDisabled),
    );
  }
}

enum ButtonSize { small, medium, large }

extension ButtonSizeX on ButtonSize {
  double getFontSize() {
    switch (this) {
      case ButtonSize.small:
        return 13.0;
      case ButtonSize.medium:
        return 15.0;
      case ButtonSize.large:
        return 18.0;
    }
  }

  double getHeight() {
    switch (this) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  TextStyle getTextStyle(BuildContext context) {
    switch (this) {
      case ButtonSize.small:
        return context.appTheme.buttonSemibold13;
      case ButtonSize.medium:
      case ButtonSize.large:
        return context.appTheme.buttonSemibold15;
    }
  }
}

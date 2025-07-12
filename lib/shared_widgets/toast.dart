import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../provider/index.dart';
import '../routes/app_router.dart';

void showError({BuildContext? context, required String message}) {
  final _context = context ?? appRouter.navigatorKey.currentContext!;
  final theme = _context.appTheme;

  toastification
    ..dismissAll(delayForAnimation: false)
    ..show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      alignment: Alignment.topCenter,
      description: Text(
        message,
        style: theme.textMedium16Default.copyWith(
          color: theme.colorError,
        ),
      ),
      icon: const Icon(Icons.error_outline),
      showIcon: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      foregroundColor: theme.colorError,
      primaryColor: theme.colorError,
    );
}

void showSuccess({BuildContext? context, required String message}) {
  final _context = context ?? appRouter.navigatorKey.currentContext!;
  final theme = _context.appTheme;
  toastification
    ..dismissAll(delayForAnimation: false)
    ..show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.minimal,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      applyBlurEffect: false,
      alignment: Alignment.topCenter,
      description: Text(
        message,
        style: theme.textMedium16Default.copyWith(
          color: theme.colorPrimary,
        ),
      ),
      icon: const Icon(Icons.check_circle_outline),
      showIcon: true, // show or hide the icon
      closeOnClick: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      closeButtonShowType: CloseButtonShowType.onHover,
      foregroundColor: theme.colorPrimary,
      primaryColor: theme.colorPrimary,
    );
}

void showSimpleInfo({BuildContext? context, required String message}) {
  final _context = context ?? appRouter.navigatorKey.currentContext!;
  final theme = _context.appTheme;
  toastification
    ..dismissAll(delayForAnimation: false)
    ..show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.minimal,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      alignment: Alignment.topCenter,
      description: Text(
        message,
        style: theme.textMedium16Default,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
    );
}

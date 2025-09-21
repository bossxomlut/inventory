import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:toastification/toastification.dart';

import '../provider/index.dart';
import '../routes/app_router.dart';

void showError({BuildContext? context, required String message}) {
  final _context = context ?? appRouter.navigatorKey.currentContext!;
  final theme = _context.appTheme;

  // Dismiss any existing toasts before showing a new one
  // showErrorSnackBar(_context, message);
  // return;

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

  // showSuccessSnackBar(_context, message);
  // return;

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

void showInfo({BuildContext? context, required String message}) {
  showSimpleInfo(context: context, message: message);
}

void showSimpleInfo({BuildContext? context, required String message}) {
  final _context = context ?? appRouter.navigatorKey.currentContext!;
  final theme = _context.appTheme;

  // showInfoSnackBar(_context, message);
  // return;

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

// Shows a Success SnackBar with a green background and checkmark icon
void showSuccessSnackBar(BuildContext context, String message) {
  final theme = context.appTheme;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thành công',
                  style: theme.textMedium13Default.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textRegular16Subtle.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.green,
        dismissDirection: DismissDirection.down,
      ),
    );
}

// Shows an Error SnackBar with a red background and error icon
void showErrorSnackBar(BuildContext context, String message) {
  final theme = context.appTheme;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lỗi',
                  style: theme.textMedium13Default.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textRegular16Subtle.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.red,
        dismissDirection: DismissDirection.down,
      ),
    );
}

// Shows an Info SnackBar with a blue background and info icon
void showInfoSnackBar(BuildContext context, String message) {
  final theme = context.appTheme;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  HugeIcons.strokeRoundedInformationCircle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thông tin',
                  style: theme.textMedium13Default.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textRegular16Subtle.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.blue,
        dismissDirection: DismissDirection.down,
      ),
    );
}

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../resource/index.dart';
import 'index.dart';

void showError({BuildContext? context, required String message}) {
  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: ToastificationType.error,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 3),
    showProgressBar: false,
    applyBlurEffect: true,
    title: const LText(LKey.error),
    alignment: Alignment.topCenter,
    // you can also use RichText widget for title and description parameters
    description: RichText(text: TextSpan(text: message)),
    // animationDuration: const Duration(milliseconds: 300),
    // animationBuilder: (context, animation, alignment, child) {
    //   return FadeTransition(
    //     opacity: animation,
    //     child: child,
    //   );
    // },
    icon: const Icon(Icons.error_outline),
    showIcon: true, // show or hide the icon
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: true,
  );
}

void showSuccess({BuildContext? context, required String message}) {
  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 3),
    showProgressBar: false,
    applyBlurEffect: true,
    title: const LText(LKey.success),
    alignment: Alignment.topCenter,
    // you can also use RichText widget for title and description parameters
    description: RichText(text: TextSpan(text: message)),
    // animationDuration: const Duration(milliseconds: 300),
    // animationBuilder: (context, animation, alignment, child) {
    //   return FadeTransition(
    //     opacity: animation,
    //     child: child,
    //   );
    // },
    icon: const Icon(Icons.check_circle_outline),
    showIcon: true, // show or hide the icon
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: true,
  );
}

void showSimpleInfo({BuildContext? context, required String message}) {
  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: ToastificationType.info,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 2),
    showProgressBar: false,
    applyBlurEffect: false,
    alignment: Alignment.center,
    description: RichText(text: TextSpan(text: message)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: true,
  );
}

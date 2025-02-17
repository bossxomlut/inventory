import 'package:flutter/material.dart';

import '../resource/index.dart';
import 'index.dart';

mixin ShowDialog<T> on Widget {
  String? get routeName => 'AppDialog';

  Future<T?> show(BuildContext context, {bool barrierDismissible = false}) {
    context.hideKeyboard();
    final theme = context.appTheme;
    return showDialog(
      context: context,
      useRootNavigator: true,
      routeSettings: RouteSettings(name: routeName),
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(40),
          child: this,
        );
      },
    );
  }
}

class AppDialog extends StatelessWidget with ShowDialog<dynamic> {
  AppDialog({
    super.key,
    this.title,
    this.description,
    this.onConfirm,
    this.onCancel,
    this.cancelText,
    this.confirmText,
  });

  final String? title;
  final String? description;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? cancelText;
  final String? confirmText;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        height: 24 / 22,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 4),
                  if (description != null)
                    Text(
                      description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 20 / 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.dividerColor,
            ),
            Row(
              children: [
                if (onCancel != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Text(
                          cancelText ?? LKey.cancel.tr(),
                          // style: theme.textRegular15Subtle.copyWith(
                          //   color: const Color(0xFF0A84FF),
                          //   fontSize: 17,
                          //   height: 22 / 17,
                          //   fontWeight: FontWeight.w600,
                          // ),
                        ),
                      ),
                    ),
                  ),
                if (onCancel != null)
                  Container(
                    height: 44,
                    width: 1,
                    color: theme.dividerColor,
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: Text(
                        confirmText ?? LKey.yes.tr(),
                        // style: theme.textRegular15Subtle.copyWith(
                        //   color: const Color(0xFF0A84FF),
                        //   fontSize: 17,
                        //   height: 22 / 17,
                        //   fontWeight: FontWeight.w600,
                        // ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

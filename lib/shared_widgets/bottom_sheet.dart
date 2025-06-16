import 'package:flutter/material.dart';

import '../provider/index.dart';
import 'index.dart';

mixin ShowBottomSheet<T> on Widget {
  Future<T?> show(BuildContext context, {bool isScafold = false}) {
    context.hideKeyboard();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      clipBehavior: Clip.antiAlias,
      backgroundColor: context.appTheme.colorBackgroundBottomSheet,
      builder: (BuildContext context) {
        final theme = context.appTheme;

        if (isScafold) {
          return this;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: this),
                ],
              ),
            ),
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      useSafeArea: true,
    );
  }
}

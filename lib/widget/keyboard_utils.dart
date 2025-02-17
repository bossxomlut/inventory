import 'package:flutter/material.dart';

extension HideKeyBoard on BuildContext {
  void hideKeyboard() {
    final FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }
}

mixin HideKeyboard<T extends StatefulWidget> on State<T> {
  void hideKeyboard() {
    context.hideKeyboard();
  }
}

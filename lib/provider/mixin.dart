import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'index.dart';

mixin CommonProvider<T> on AutoDisposeNotifier<T> {
  ///Provider used to manage loading state
  void showLoading() {
    ref.read(isLoadingProvider.notifier).state = true;
  }

  void hideLoading() {
    ref.read(isLoadingProvider.notifier).state = false;
  }

  ///Provider used to manage notification state
  void showSuccess(String message) {
    ref.read(notificationProvider.notifier).showSuccess(message);
  }

  void showError(String message) {
    ref.read(notificationProvider.notifier).showError(message);
  }

  void showWarning(String message) {
    ref.read(notificationProvider.notifier).showWarning(message);
  }
}

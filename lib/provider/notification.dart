import 'package:riverpod/riverpod.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => NotificationNotifier());

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState.hide());

  void showSuccess(String message) {
    state = NotificationState.success(message);
  }

  void showError(String message) {
    state = NotificationState.error(message);
  }

  void showWarning(String message) {
    state = NotificationState.warning(message);
  }

  void hide() {
    state = NotificationState.hide();
  }
}

class NotificationState {
  NotificationState({
    required this.isShow,
    required this.message,
    required this.type,
  }) {
    if (isShow) {
      assert(message != null);
      assert(type != null);
    }
  }

  final bool isShow;
  final String? message;
  final NotificationType? type;

  factory NotificationState.hide() {
    return NotificationState(
      isShow: false,
      message: null,
      type: null,
    );
  }

  factory NotificationState.success(String message) {
    return NotificationState(
      isShow: true,
      message: message,
      type: NotificationType.success,
    );
  }
  factory NotificationState.error(String message) {
    return NotificationState(
      isShow: true,
      message: message,
      type: NotificationType.error,
    );
  }

  factory NotificationState.warning(String message) {
    return NotificationState(
      isShow: true,
      message: message,
      type: NotificationType.warning,
    );
  }
}

enum NotificationType { success, error, warning }

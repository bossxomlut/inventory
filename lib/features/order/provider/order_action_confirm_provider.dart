import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/authentication/provider/auth_provider.dart';
import '../../../provider/index.dart';
import '../../../logger.dart';

part 'order_action_confirm_provider.g.dart';

enum OrderActionType { confirm, cancel, delete }

class OrderActionConfirmSettings {
  const OrderActionConfirmSettings({
    required this.confirm,
    required this.cancel,
    required this.delete,
  });

  const OrderActionConfirmSettings.defaults()
      : confirm = true,
        cancel = true,
        delete = true;

  final bool confirm;
  final bool cancel;
  final bool delete;

  bool isEnabled(OrderActionType type) {
    switch (type) {
      case OrderActionType.confirm:
        return confirm;
      case OrderActionType.cancel:
        return cancel;
      case OrderActionType.delete:
        return delete;
    }
  }

  OrderActionConfirmSettings copyWith({
    bool? confirm,
    bool? cancel,
    bool? delete,
  }) {
    return OrderActionConfirmSettings(
      confirm: confirm ?? this.confirm,
      cancel: cancel ?? this.cancel,
      delete: delete ?? this.delete,
    );
  }

  Map<String, dynamic> toJson() => {
        'confirm': confirm,
        'cancel': cancel,
        'delete': delete,
      };

  factory OrderActionConfirmSettings.fromJson(Map<String, dynamic> json) {
    return OrderActionConfirmSettings(
      confirm: json['confirm'] as bool? ?? true,
      cancel: json['cancel'] as bool? ?? true,
      delete: json['delete'] as bool? ?? true,
    );
  }
}

@Riverpod(keepAlive: true)
class OrderActionConfirmController extends _$OrderActionConfirmController {
  static const String _storageKeyPrefix = 'order_action_confirm_settings';

  int get _currentUserId {
    final authState = ref.read(authControllerProvider);
    return authState.maybeWhen(
      authenticated: (user, _) => user.id,
      orElse: () => -1,
    );
  }

  String _storageKey(int userId) => '${_storageKeyPrefix}_$userId';

  @override
  Future<OrderActionConfirmSettings> build() async {
    final storage = ref.read(simpleStorageProvider);
    await storage.init();

    final userId = _currentUserId;
    final raw = await storage.getString(_storageKey(userId));
    if (raw == null) {
      return const OrderActionConfirmSettings.defaults();
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return OrderActionConfirmSettings.fromJson(map);
    } catch (_) {
      return const OrderActionConfirmSettings.defaults();
    }
  }

  Future<void> setActionEnabled(OrderActionType type, bool enabled) async {
    final current = await future;
    final updated = current.copyWith(
      confirm: type == OrderActionType.confirm ? enabled : current.confirm,
      cancel: type == OrderActionType.cancel ? enabled : current.cancel,
      delete: type == OrderActionType.delete ? enabled : current.delete,
    );
    await _save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> reset() async {
    const defaults = OrderActionConfirmSettings.defaults();
    await _save(defaults);
    state = const AsyncValue.data(defaults);
  }

  Future<void> _save(OrderActionConfirmSettings settings) async {
    final storage = ref.read(simpleStorageProvider);
    await storage.init();
    final userId = _currentUserId;
    await storage.saveString(
      _storageKey(userId),
      jsonEncode(settings.toJson()),
    );
    userConfigLogger.i(
      '[OrderActionConfirm] Saved for user $userId -> ${settings.toJson()}',
    );
  }
}

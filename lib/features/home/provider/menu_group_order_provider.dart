import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/authentication/provider/auth_provider.dart';
import '../../../provider/index.dart';
import '../menu_manager.dart';

part 'menu_group_order_provider.g.dart';

@Riverpod(keepAlive: true)
class MenuGroupOrderController extends _$MenuGroupOrderController {
  static const String _storageKeyPrefix = 'menu_group_order';

  int get _currentUserId {
    final authState = ref.read(authControllerProvider);
    return authState.maybeWhen(
      authenticated: (user, _) => user.id,
      orElse: () => -1,
    );
  }

  String _storageKey(int userId) => '${_storageKeyPrefix}_$userId';

  @override
  Future<List<MenuGroupId>> build() async {
    final storage = ref.read(simpleStorageProvider);
    await storage.init();

    final userId = _currentUserId;
    final stored = await storage.getStringList(_storageKey(userId));
    if (stored == null) {
      return const [];
    }

    final result = <MenuGroupId>[];
    for (final entry in stored) {
      try {
        result.add(MenuGroupId.values.byName(entry));
      } catch (_) {
        // ignore unknown entries
      }
    }
    return result;
  }

  Future<void> saveOrder(List<MenuGroupId> order) async {
    final storage = ref.read(simpleStorageProvider);
    await storage.init();
    final userId = _currentUserId;
    await storage.saveStringList(
      _storageKey(userId),
      order.map((id) => id.name).toList(),
    );
    debugPrint('[MenuGroupOrder] Saved for user $userId -> ${order.map((e) => e.name).toList()}');
    state = AsyncValue.data(List<MenuGroupId>.from(order));
  }

  Future<void> reset() async {
    final storage = ref.read(simpleStorageProvider);
    await storage.init();
    final userId = _currentUserId;
    await storage.remove(_storageKey(userId));
    debugPrint('[MenuGroupOrder] Reset for user $userId');
    state = const AsyncValue.data([]);
  }
}

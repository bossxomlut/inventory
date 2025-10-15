import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sample_app/core/persistence/simple_key_value_storage.dart';
import 'package:sample_app/features/order/provider/order_action_confirm_provider.dart';
import 'package:sample_app/provider/storage_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SimpleStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = SimpleStorage();
    await storage.init();
  });

  test('default settings enable all confirmations', () async {
    final container = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(container.dispose);

    final settings = await container.read(orderActionConfirmControllerProvider.future);
    expect(settings.confirm, isTrue);
    expect(settings.cancel, isTrue);
    expect(settings.delete, isTrue);
  });

  test('persist and restore settings per user', () async {
    final container = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(container.dispose);

    final notifier = container.read(orderActionConfirmControllerProvider.notifier);
    await notifier.setActionEnabled(OrderActionType.confirm, false);

    final updated = await container.read(orderActionConfirmControllerProvider.future);
    expect(updated.confirm, isFalse);

    final newContainer = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(newContainer.dispose);

    final restored = await newContainer.read(orderActionConfirmControllerProvider.future);
    expect(restored.confirm, isFalse);
    expect(restored.cancel, isTrue);
  });

  test('reset restores defaults', () async {
    final container = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(container.dispose);

    final notifier = container.read(orderActionConfirmControllerProvider.notifier);
    await notifier.setActionEnabled(OrderActionType.delete, false);
    await notifier.reset();

    final settings = await container.read(orderActionConfirmControllerProvider.future);
    expect(settings.delete, isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sample_app/features/home/menu_manager.dart';
import 'package:sample_app/features/home/provider/menu_group_order_provider.dart';
import 'package:sample_app/provider/storage_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SimpleStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = SimpleStorage();
    await storage.init();
  });

  test('returns empty list when no preference saved', () async {
    final container = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(container.dispose);

    final order = await container.read(menuGroupOrderControllerProvider.future);
    expect(order, isEmpty);
  });

  test('saves and restores menu order', () async {
    final container = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(container.dispose);

    final notifier = container.read(menuGroupOrderControllerProvider.notifier);
    await notifier.saveOrder(const [
      MenuGroupId.dataManagement,
      MenuGroupId.priceAndOrder,
    ]);

    final saved = await container.read(menuGroupOrderControllerProvider.future);
    expect(saved, [MenuGroupId.dataManagement, MenuGroupId.priceAndOrder]);

    final newContainer = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(newContainer.dispose);

    final restored = await newContainer.read(menuGroupOrderControllerProvider.future);
    expect(restored, [MenuGroupId.dataManagement, MenuGroupId.priceAndOrder]);
  });

  test('reset clears stored order', () async {
    final container = ProviderContainer(overrides: [
      simpleStorageProvider.overrideWithValue(storage),
    ]);

    addTearDown(container.dispose);

    final notifier = container.read(menuGroupOrderControllerProvider.notifier);
    await notifier.saveOrder(const [MenuGroupId.systemAdministration]);
    await notifier.reset();

    final order = await container.read(menuGroupOrderControllerProvider.future);
    expect(order, isEmpty);
  });
}

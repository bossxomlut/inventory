import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/persistence/simple_key_value_storage.dart';

/// Global provider for SimpleStorage
/// This provider ensures a single instance is used throughout the app
/// and handles initialization automatically
final simpleStorageProvider = Provider<SimpleStorage>((ref) {
  return SimpleStorage();
});

/// Provider that ensures SimpleStorage is initialized
/// Use this when you need to ensure the storage is ready to use
final initializedSimpleStorageProvider = FutureProvider<SimpleStorage>((ref) async {
  final storage = ref.read(simpleStorageProvider);
  await storage.init();
  return storage;
});

/// Provider for checking if storage is initialized
final isStorageInitializedProvider = StateProvider<bool>((ref) => false);

/// Helper provider to initialize storage and update state
final storageInitializerProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(simpleStorageProvider);
  await storage.init();
  ref.read(isStorageInitializedProvider.notifier).state = true;
});

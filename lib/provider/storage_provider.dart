import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/persistence/simple_key_value_storage.dart';

/// Global provider for SimpleStorage
/// This provider ensures a single instance is used throughout the app
/// and handles initialization automatically
final simpleStorage = SimpleStorage();

final simpleStorageProvider = Provider<SimpleStorage>((ref) => simpleStorage);

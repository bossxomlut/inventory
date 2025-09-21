import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sample_app/core/persistence/simple_key_value_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('init is idempotent', () async {
    final storage = SimpleStorage();
    await storage.init();
    await storage.init();

    await storage.saveString('key', 'value');
    expect(await storage.getString('key'), 'value');
  });

  test('save and retrieve string list', () async {
    final storage = SimpleStorage();
    await storage.init();

    await storage.saveStringList('languages', ['dart', 'kotlin']);
    expect(await storage.getStringList('languages'), ['dart', 'kotlin']);
  });

  test('remove clears persisted value', () async {
    final storage = SimpleStorage();
    await storage.init();

    await storage.saveBool('flag', true);
    await storage.remove('flag');
    expect(await storage.getBool('flag'), isNull);
  });
}

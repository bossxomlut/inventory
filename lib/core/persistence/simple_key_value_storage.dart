import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_storage.dart';

/// Data may be persisted to disk asynchronously,
/// and there is no guarantee that writes will be persisted to disk after returning,
/// so this plugin must not be used for storing critical data.

@singleton
class SimpleStorage extends KeyValueStorage {
  static const String firstLaunchKey = 'firstLaunch';

  late final SharedPreferences _prefs;

  bool _isInitialized = false;

  @override
  Future<void> clear() {
    return _prefs.clear();
  }

  @override
  Future<bool?> getBool(String key) {
    return Future.sync(() => _prefs.getBool(key));
  }

  @override
  Future<double?> getDouble(String key) {
    return Future.sync(() => _prefs.getDouble(key));
  }

  @override
  Future<int?> getInt(String key) {
    return Future.sync(() => _prefs.getInt(key));
  }

  @override
  Future<String?> getString(String key) {
    return Future.sync(() => _prefs.getString(key));
  }

  @override
  Future<List<String>?> getStringList(String key) {
    return Future.sync(() => _prefs.getStringList(key));
  }

  @override
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  @override
  Future<void> remove(String key) {
    return _prefs.remove(key);
  }

  @override
  Future<void> saveBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  @override
  Future<void> saveDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  @override
  Future<void> saveInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  @override
  Future<void> saveString(String key, String value) {
    return _prefs.setString(key, value);
  }

  @override
  Future<void> saveStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }
}

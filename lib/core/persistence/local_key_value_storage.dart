import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:isar_key_value/isar_key_value.dart';
import 'package:path_provider/path_provider.dart';

import '../../injection/injection.dart';
import 'key_value_storage.dart';
import 'object_storage.dart';

@singleton
class LocalKeyValueStorage implements KeyValueStorage, ObjectStorage {
  LocalKeyValueStorage();

  IsarKeyValue get _isarKeyValue => getIt.get<IsarKeyValue>();

  @override
  Future<void> clear() {
    return _isarKeyValue.clear();
  }

  @override
  Future<bool?> getBool(String key) {
    return _isarKeyValue.get(key);
  }

  @override
  Future<double?> getDouble(String key) {
    return _isarKeyValue.get(key);
  }

  @override
  Future<int?> getInt(String key) {
    return _isarKeyValue.get(key);
  }

  @override
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> fromJson) function) async {
    final data = (await _isarKeyValue.get<String>(key)) ?? '';

    return function(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<String?> getString(String key) {
    return _isarKeyValue.get(key);
  }

  @override
  Future<List<String>?> getStringList(String key) {
    return _isarKeyValue.get(key);
  }

  @override
  Future<void> init() async {
    if (getIt.isRegistered<IsarKeyValue>()) {
      return;
    }
    final String path = (await getApplicationDocumentsDirectory()).path;

    getIt.registerSingleton<IsarKeyValue>(IsarKeyValue(directory: path));
  }

  @override
  Future<void> remove(String key) {
    return _isarKeyValue.remove(key);
  }

  @override
  Future<void> removeObject(String key) {
    return _isarKeyValue.remove(key);
  }

  @override
  Future<void> saveBool(String key, bool value) {
    return _isarKeyValue.set(key, value);
  }

  @override
  Future<void> saveDouble(String key, double value) {
    return _isarKeyValue.set(key, value);
  }

  @override
  Future<void> saveInt(String key, int value) {
    return _isarKeyValue.set(key, value);
  }

  @override
  Future<void> saveObject<T>(String key, T value, Map Function(T value) toJson) {
    return _isarKeyValue.set(key, jsonEncode(toJson(value)));
  }

  @override
  Future<void> saveString(String key, String value) {
    return _isarKeyValue.set(key, value);
  }

  @override
  Future<void> saveStringList(String key, List<String> value) {
    return _isarKeyValue.set(key, value);
  }
}

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'key_value_storage.dart';
import 'object_storage.dart';

@singleton
class SecurityStorage implements KeyValueStorage, ObjectStorage {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> clear() => _storage.deleteAll();

  @override
  Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? null : value == 'true';
  }

  @override
  Future<double?> getDouble(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? null : double.tryParse(value);
  }

  @override
  Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? null : int.tryParse(value);
  }

  @override
  Future<String?> getString(String key) => _storage.read(key: key);

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as List<String>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> remove(String key) => _storage.delete(key: key);

  @override
  Future<void> removeObject(String key) => _storage.delete(key: key);

  @override
  Future<void> saveBool(String key, bool value) => _storage.write(key: key, value: value.toString());

  @override
  Future<void> saveDouble(String key, double value) => _storage.write(key: key, value: value.toString());

  @override
  Future<void> saveInt(String key, int value) => _storage.write(key: key, value: value.toString());

  @override
  Future<void> saveString(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> saveStringList(String key, List<String> value) => _storage.write(key: key, value: jsonEncode(value));

  @override
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    try {
      return fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveObject<T>(String key, T value, Map Function(T value) toJson) {
    return _storage.write(key: key, value: jsonEncode(toJson(value)));
  }
}

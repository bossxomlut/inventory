abstract class KeyValueStorage {
  Future<void> init();

  Future<void> saveString(String key, String value);

  Future<String?> getString(String key);

  Future<void> saveInt(String key, int value);

  Future<int?> getInt(String key);

  Future<void> saveBool(String key, bool value);

  Future<bool?> getBool(String key);

  Future<void> saveDouble(String key, double value);

  Future<double?> getDouble(String key);

  Future<void> saveStringList(String key, List<String> value);

  Future<List<String>?> getStringList(String key);

  Future<void> remove(String key);

  Future<void> clear();
}

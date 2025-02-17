abstract class ObjectStorage {
  Future<void> saveObject<T>(String key, T value, Map Function(T value) toJson);

  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> fromJson));

  Future<void> removeObject(String key);

  Future<void> clear();
}

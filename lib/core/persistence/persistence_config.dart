import '../../injection/injection.dart';
import 'local_key_value_storage.dart';
import 'security_storage.dart';
import 'simple_key_value_storage.dart';

abstract class PersistenceConfig {
  static Future<void> init() {
    return Future.wait([
      getIt.get<SimpleStorage>().init(),
      getIt.get<SecurityStorage>().init(),
      getIt.get<LocalKeyValueStorage>().init(),
      //getIt.get<IsarDatabase>().initialize(),
    ]);
  }
}

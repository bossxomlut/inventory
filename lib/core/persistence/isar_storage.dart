import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/model/index.dart';

class IsarDatabase {
  @override
  Future initialize() {
    return Isar.initializeIsarCore().whenComplete(() {
      return getApplicationDocumentsDirectory().then(
        (dir) {
          return Isar.open(
            [
              UserCollectionSchema,
            ],
            directory: dir.path,
          );
        },
      );
    });
  }
}

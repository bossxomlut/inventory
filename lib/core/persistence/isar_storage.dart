import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/model/index.dart';
import '../../data/model/inventory.dart';

class IsarDatabase {
  @override
  Future initialize() {
    return Isar.initializeIsarCore().whenComplete(() {
      return getApplicationDocumentsDirectory().then(
        (dir) {
          return Isar.open(
            [
              UserCollectionSchema,
              ProductCollectionSchema,
              CategoryCollectionSchema,
            ],
            directory: dir.path,
          );
        },
      );
    });
  }
}

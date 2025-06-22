import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/check/check_collection.dart';
import '../../data/image/image.dart';
import '../../data/product/inventory.dart';
import '../../data/user/user.dart';

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
              ImageStorageCollectionSchema,
              CheckSessionCollectionSchema,
              CheckedProductCollectionSchema,
              UnitCollectionSchema,
            ],
            directory: dir.path,
          );
        },
      );
    });
  }
}

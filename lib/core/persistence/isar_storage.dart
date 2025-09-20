import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/check/check_collection.dart';
import '../../data/image/image.dart';
import '../../data/order/order.dart';
import '../../data/order/product_price.dart';
import '../../data/product/inventory.dart';
import '../../data/user/user.dart';
import '../../data/user/user_permission.dart';
import '../../domain/index.dart';
import 'index.dart';

class IsarDatabase {
  @override
  Future initialize() {
    return getApplicationDocumentsDirectory().then(
      (dir) async {
        String directory = dir.path;

        final SecurityStorage securityStorage = SecurityStorage();

        final authState =
            await securityStorage.getObject('auth_state', AuthState.fromJson);

        authState?.whenOrNull(
          authenticated: (User user, DateTime? lastLoginTime) {
            if (user.role == UserRole.guest) {
              directory = '${dir.path}/guest';
              //create directory if not exists
              final guestDir = Directory(directory);
              if (!guestDir.existsSync()) {
                guestDir.createSync(recursive: true);
              }
            }
          },
        );

        await Isar.open(
          [
            UserCollectionSchema,
            ProductCollectionSchema,
            CategoryCollectionSchema,
            ImageStorageCollectionSchema,
            CheckSessionCollectionSchema,
            CheckedProductCollectionSchema,
            UnitCollectionSchema,
            TransactionCollectionSchema,
            ProductPriceCollectionSchema,
            OrderItemCollectionSchema,
            OrderCollectionSchema,
            UserPermissionCollectionSchema,
          ],
          directory: directory,
        );
      },
    );
  }
}

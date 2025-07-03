import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/check/check_collection.dart';
import '../../data/image/image.dart';
import '../../data/order/order.dart';
import '../../data/order/product_price.dart';
import '../../data/product/inventory.dart';
import '../../data/user/user.dart';
import '../../domain/index.dart';
import 'index.dart';

class IsarDatabase {
  @override
  Future initialize() {
    return getApplicationDocumentsDirectory().then(
      (dir) async {
        String directory = dir.path;

        final SecurityStorage securityStorage = SecurityStorage();

        final authState = await securityStorage.getObject('auth_state', AuthState.fromJson);

        authState?.whenOrNull(
          authenticated: (User user, DateTime? lastLoginTime) {
            if (user.role == UserRole.guest) {
              directory = '${dir.path}/guest';
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
          ],
          directory: directory,
        );
      },
    );
  }
}

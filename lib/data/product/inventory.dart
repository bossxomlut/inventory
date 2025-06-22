import 'package:isar/isar.dart';

import '../image/image.dart';
import '../isar/schema/unit_collection.dart';

part 'inventory.g.dart';

@collection
class CategoryCollection {
  Id id = Isar.autoIncrement;
  late String name;
  late String? description;
  DateTime? createDate;
  DateTime? updatedDate;
}

@collection
class ProductCollection {
  Id id = Isar.autoIncrement;
  late String name;
  late String? barcode;
  late double? price;
  late int quantity;
  final IsarLink<CategoryCollection> category = IsarLink<CategoryCollection>();
  final IsarLink<UnitCollection> unit = IsarLink<UnitCollection>();
  final IsarLinks<ImageStorageCollection> images = IsarLinks<ImageStorageCollection>();
  late String? description;
  late DateTime createdAt;
  late DateTime updatedAt;
}

@collection
class TransactionCollection {
  Id id = Isar.autoIncrement;
  late int productId;
  late int quantity;
  late int type; // 0 for import, 1 for export
  late DateTime timestamp;
  late String userId;
  late int transactionType;
}

import 'package:isar/isar.dart';

import '../../domain/entities/product/inventory.dart';
import '../image/image.dart';

part 'inventory.g.dart';

@collection
class ProductCollection {
  Id id = Isar.autoIncrement;
  late String name;
  late String? barcode;
  late int quantity;
  late bool enableExpiryTracking;
  final IsarLink<CategoryCollection> category = IsarLink<CategoryCollection>();
  final IsarLink<UnitCollection> unit = IsarLink<UnitCollection>();
  final IsarLinks<ImageStorageCollection> images =
      IsarLinks<ImageStorageCollection>();
  @Backlink(to: 'product')
  final IsarLinks<InventoryLotCollection> lots =
      IsarLinks<InventoryLotCollection>();
  late String? description;
  late DateTime createdAt;
  late DateTime updatedAt;
}

@collection
class CategoryCollection {
  Id id = Isar.autoIncrement;
  late String name;
  late String? description;
  DateTime? createDate;
  DateTime? updatedDate;
}

@collection
class UnitCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? description;

  DateTime? createDate;

  DateTime? updatedDate;
}

@collection
class TransactionCollection {
  Id id = Isar.autoIncrement;

  // Link to the related product
  @Index()
  late int productId;

  // Link to the inventory lot when applicable
  @Index()
  int? inventoryLotId;

  // Transaction quantity
  late int quantity;

  // Transaction type defined by the enum for clarity
  @enumerated
  late TransactionType type;

  // Timestamp of the transaction
  @Index(type: IndexType.value)
  late DateTime timestamp;

  // Optional extra transaction category when finer classification is needed
  @enumerated
  late TransactionCategory category;
}

@collection
class InventoryLotCollection {
  Id id = Isar.autoIncrement;

  @Index(
    unique: true,
    composite: [
      CompositeIndex('expiryDate'),
      CompositeIndex('manufactureDate'),
    ],
  )
  late int productId;

  late int quantity;

  @Index(type: IndexType.value)
  late DateTime expiryDate;

  DateTime? manufactureDate;

  late DateTime createdAt;
  late DateTime updatedAt;

  final product = IsarLink<ProductCollection>();
}

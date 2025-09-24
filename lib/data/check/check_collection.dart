import 'package:isar/isar.dart';

import '../../domain/entities/check/check_session.dart';
import '../product/inventory.dart';

part 'check_collection.g.dart';

@collection
class CheckSessionCollection {
  Id id = Isar.autoIncrement;
  late String name;
  late DateTime startDate;
  DateTime? endDate;
  late String createdBy;
  @enumerated
  late CheckSessionStatus status;
  String? note;
}

@collection
class CheckedProductCollection {
  Id id = Isar.autoIncrement;
  late int expectedQuantity;
  late int actualQuantity;
  late DateTime checkDate;
  String? note;

  final IsarLink<CheckSessionCollection> session =
      IsarLink<CheckSessionCollection>();
  final IsarLink<ProductCollection> product = IsarLink<ProductCollection>();
  @Backlink(to: 'checkedProduct')
  final IsarLinks<CheckedInventoryLotCollection> lots =
      IsarLinks<CheckedInventoryLotCollection>();
}

@collection
class CheckedInventoryLotCollection {
  Id id = Isar.autoIncrement;
  int? inventoryLotId;
  late DateTime expiryDate;
  DateTime? manufactureDate;
  late int expectedQuantity;
  late int actualQuantity;

  final IsarLink<CheckedProductCollection> checkedProduct =
      IsarLink<CheckedProductCollection>();
}

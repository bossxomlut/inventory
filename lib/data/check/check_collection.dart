import 'package:isar/isar.dart';

import '../../domain/entities/check/check.dart';
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
  String? note;
  late String checkedBy;
  late DateTime checkDate;

  final IsarLink<CheckSessionCollection> session = IsarLink<CheckSessionCollection>();
  final IsarLink<ProductCollection> product = IsarLink<ProductCollection>();
}

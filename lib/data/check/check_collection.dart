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
  late String checkedBy; // Thêm trường người kiểm kê
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

  final IsarLink<CheckSessionCollection> session = IsarLink<CheckSessionCollection>();
  final IsarLink<ProductCollection> product = IsarLink<ProductCollection>();
}

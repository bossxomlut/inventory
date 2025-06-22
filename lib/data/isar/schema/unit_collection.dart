import 'package:isar/isar.dart';

part 'unit_collection.g.dart';

@collection
class UnitCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? description;

  DateTime? createDate;

  DateTime? updatedDate;
}

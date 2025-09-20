import 'package:isar/isar.dart';

part 'user_permission.g.dart';

@collection
class UserPermissionCollection {
  Id id = Isar.autoIncrement;

  @Index()
  late int userId;

  @Index(caseSensitive: false)
  late String permissionKey;

  bool isEnabled = true;
}

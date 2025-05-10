import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class UserCollection {
  Id id = Isar.autoIncrement;
  late String account;
  late String password;
  late int role;
}

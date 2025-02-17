import 'package:uuid/uuid.dart';

String generateShortUuid() {
  var uuid = Uuid();
  return uuid.v4().substring(0, 8); // Lấy 8 ký tự đầu
}

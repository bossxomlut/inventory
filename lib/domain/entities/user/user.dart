import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id, // Mã người dùng
    required String username, // Tên đăng nhập
    required UserRole role, // Vai trò (admin/user/guest)
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

enum UserRole {
  admin,
  user,
  guest,
}

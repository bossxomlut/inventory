import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id, // Mã người dùng
    required String username, // Tên đăng nhập
    required UserRole role, // Vai trò (admin/user/guest)
    @Default(false) bool isActive, // Trạng thái hoạt động
    DateTime? createdAt, // Thời gian tạo
    DateTime? lastLoginAt, // Lần đăng nhập cuối
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

enum UserRole {
  admin,
  user,
  guest,
}

//create extension displayName for UserRole
extension UserRoleX on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.user:
        return 'User';
      case UserRole.guest:
        return 'Guest';
    }
  }
}

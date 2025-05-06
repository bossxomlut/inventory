// Model cho Người dùng (User)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id, // Mã người dùng
    required String username, // Tên đăng nhập
    required String role, // Vai trò (admin/user)
  }) = _User;
}

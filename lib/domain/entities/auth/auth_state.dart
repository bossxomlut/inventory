import 'package:freezed_annotation/freezed_annotation.dart';

import '../user/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated({
    required User user, // Thông tin người dùng
    DateTime? lastLoginTime, // Thời gian đăng nhập gần nhất
  }) = Authenticated;

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.initial() = Initial;

  factory AuthState.fromJson(Map<String, dynamic> json) {
    final user = json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null;

    if (user != null) {
      return AuthState.authenticated(
        user: user,
        lastLoginTime: json['lastLoginTime'] != null ? DateTime.parse(json['lastLoginTime'] as String) : null,
      );
    }
    return const AuthState.unauthenticated();
  }
}

extension AuthStateX on AuthState {
  Map<String, dynamic> toJson() => when(
        authenticated: (user, lastLoginTime) => {
          'user': user.toJson(),
          'lastLoginTime': lastLoginTime?.toIso8601String(),
        },
        unauthenticated: () => {},
        initial: () => {},
      );
}

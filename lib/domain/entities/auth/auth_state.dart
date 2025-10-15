import 'package:freezed_annotation/freezed_annotation.dart';

import '../user/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated({
    required User user, // Authenticated user information
    DateTime? lastLoginTime, // Timestamp of the last login
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

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    required String userName,
    required String password,
  }) = _LoginState;
}

extension LoginStateX on LoginState {
  bool get isValid => userName.isNotEmpty && password.isNotEmpty;
}

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    required String userName,
    required String password,
    required String confirmPassword,
    required UserRole role,
    required int securityQuestionId,
    required String securityAnswer,
    required bool isExistAdmin,
  }) = _SignUpState;
}

extension SignUpStateX on SignUpState {
  bool get isValid =>
      userName.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      securityQuestionId > 0 &&
      securityAnswer.isNotEmpty;
}

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    required String userAccount,
    required int securityQuestionId,
    required String securityAnswer,
    required String password,
    required String confirmPassword,
  }) = _ForgotPasswordState;
}

extension ForgotPasswordStateX on ForgotPasswordState {
  bool get isValidSecurityInfo => userAccount.isNotEmpty && securityQuestionId != -1 && securityAnswer.isNotEmpty;

  bool get isValidPassword => password.isNotEmpty && confirmPassword.isNotEmpty;
}

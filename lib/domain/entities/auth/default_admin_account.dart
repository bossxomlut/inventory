import '../user/user.dart';

/// Immutable description of the built-in administrator account that ships with
/// the application. Keeping the data in one place simplifies future updates
/// and avoids scattering hard-coded credentials throughout the codebase.
class DefaultAccountInfo {
  const DefaultAccountInfo({
    required this.username,
    required this.password,
    required this.role,
    required this.securityQuestionId,
    required this.securityAnswer,
  });

  final String username;
  final String password;
  final UserRole role;
  final int securityQuestionId;
  final String securityAnswer;
}

const DefaultAccountInfo defaultAdminAccount = DefaultAccountInfo(
  username: 'admin',
  password: 'admin',
  role: UserRole.admin,
  securityQuestionId: 1,
  securityAnswer: 'red',
);

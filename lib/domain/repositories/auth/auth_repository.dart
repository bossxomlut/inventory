import 'package:riverpod/riverpod.dart';

import '../../../data/auth/auth_repository.dart';
import '../../index.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

abstract class AuthRepository {
  Future<bool> checkExistAdmin();
  Future<User> login(String account, String password);
  Future<User> register(
    String account,
    String password,
    UserRole role,
    int securityQuestionId,
    String securityQuestionAnswer,
  );
  Future<void> logout();

  Future<bool> checkSecurityQuestion(String account, int securityQuestionId, String answer);

  Future<void> updatePassword(String account, String password);
}

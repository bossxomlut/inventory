import 'package:riverpod/riverpod.dart';

import '../../data/repositories/index.dart';
import '../index.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

abstract class AuthRepository {
  Future<User> login(String account, String password);
  Future<User> register(String account, String password, UserRole role);
  Future<void> logout();
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/index.dart';
import '../../../domain/index.dart';
import '../../../routes/app_router.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  static const String _authStateKey = 'auth_state';

  @override
  AuthState build() => const AuthState.initial();

  // Initialize AuthState

  // Load AuthState from SharedPreferences
  Future<void> checkLogin() async {
    final AuthState authState = await _loadAuthData();
    try {
      authState.maybeWhen(
        orElse: () {
          appRouter.goToLogin();
        },
        authenticated: (user, DateTime? lastLoginTime) {
          appRouter.goHome();
        },
      );
    } catch (e) {
      appRouter.goToLogin();
    }

    state = authState;
  }

  Future<AuthState> _loadAuthData() async {
    try {
      final prefs = ref.read(securityStorageProvider);
      final authState = await prefs.getObject(_authStateKey, AuthState.fromJson);

      if (authState != null) {
        return authState;
      }
    } catch (e) {}
    return const AuthState.unauthenticated();
  }

  // Save AuthState to SharedPreferences
  Future<void> _saveAuthState(AuthState state) async {
    final prefs = ref.read(securityStorageProvider);
    await prefs.saveObject<AuthState>(
      _authStateKey,
      state,
      (value) => state.toJson(),
    );
  }

  // Login method
  Future<void> login({
    required String id,
    required String username,
    required UserRole role,
  }) async {
    final newState = AuthState.authenticated(
      user: User(
        id: id,
        username: username,
        role: role,
      ),
      lastLoginTime: DateTime.now(),
    );
    state = newState;
    await _saveAuthState(newState);
  }

  // Logout method
  Future<void> logout() async {
    state = const AuthState.unauthenticated();
    final prefs = ref.read(securityStorageProvider);
    prefs.removeObject(_authStateKey);
    appRouter.goToLogin();
  }
}

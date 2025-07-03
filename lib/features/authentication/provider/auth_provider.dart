import 'package:isar/isar.dart';
import 'package:restart_app/restart_app.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/index.dart';
import '../../../domain/index.dart';
import '../../../domain/repositories/auth/pin_code_repository.dart';
import '../../../routes/app_router.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  static const String _authStateKey = 'auth_state';

  @override
  AuthState build() => const AuthState.initial();

  // Initialize AuthState

  // Load AuthState from SharedPreferences
  Future<void> checkLogin() async {
    final AuthState authState = await _loadAuthData();
    state = authState;

    try {
      authState.maybeWhen(
        orElse: () {
          appRouter.goToLogin();
        },
        authenticated: (user, DateTime? lastLoginTime) {
          final pinCodeRepository = ref.read(pinCodeRepositoryProvider);
          pinCodeRepository.isSetPinCode.then(
            (bool value) {
              if (value) {
                appRouter.goToLoginByPinCode();
              } else {
                appRouter.goHome();
              }
            },
          );
        },
      );
    } catch (e) {
      appRouter.goToLogin();
    }
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
    required int id,
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

  //guest login method
  Future<void> guestLogin() async {
    final newState = AuthState.authenticated(
      user: User(
        id: -1,
        username: 'Guest',
        role: UserRole.guest,
      ),
      lastLoginTime: DateTime.now(),
    );
    state = newState;
    await _saveAuthState(newState);

    await Isar.getInstance()!.close();

    //kill and restart the app to apply guest mode
    Restart.restartApp(
      /// In Web Platform, Fill webOrigin only when your new origin is different than the app's origin
      // webOrigin: 'http://example.com',

      // Customizing the notification message only on iOS
      notificationTitle: 'Restarting App',
      notificationBody: 'Please tap here to open the app again.',
    );
  }

  // Logout method
  Future<void> logout() async {
    //check if use is guest
    final isGuest = state.maybeWhen(
      authenticated: (user, lastLoginTime) => user.role == UserRole.guest,
      orElse: () => false,
    );
    if (isGuest) {
      state = const AuthState.unauthenticated();
      final prefs = ref.read(securityStorageProvider);
      prefs.removeObject(_authStateKey);

      await Isar.getInstance()!.close();

      //kill and restart the app to apply guest mode
      Restart.restartApp(
        /// In Web Platform, Fill webOrigin only when your new origin is different than the app's origin
        // webOrigin: 'http://example.com',

        // Customizing the notification message only on iOS
        notificationTitle: 'Restarting App',
        notificationBody: 'Please tap here to open the app again.',
      );
    } else {
      state = const AuthState.unauthenticated();
      final prefs = ref.read(securityStorageProvider);
      await prefs.removeObject(_authStateKey);
      appRouter.goToLogin();
    }
  }
}

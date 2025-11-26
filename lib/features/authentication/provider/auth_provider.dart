import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:isar_community/isar.dart';
import 'package:restart_app/restart_app.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/index.dart';
import '../../../domain/index.dart';
import '../../../domain/repositories/auth/pin_code_repository.dart';
import '../../../features/data_management/services/data_import_service.dart';
import '../../../features/data_management/provider/sample_data_onboarding_provider.dart';
import '../../../features/data_management/services/admin_sample_data_prompt_service.dart';
import '../../../provider/notification.dart';
import '../../../resources/index.dart';
import '../../../provider/storage_provider.dart';
import '../../../routes/app_router.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  static const String _authStateKey = 'auth_state';
  static const String _isCreatedGuestData = 'is_created_guest_data';

  @override
  AuthState build() => const AuthState.initial();

  // Initialize AuthState

  // Load AuthState from SharedPreferences
  Future<void> checkLogin() async {
    final AuthState authState = await _loadAuthData();
    state = authState;

    try {
      final user =
          authState.whenOrNull(authenticated: (user, DateTime? lastLogin) => user);
      if (user == null) {
        appRouter.goToLogin();
        return;
      }

      await _handleAuthenticatedUser(user);
    } catch (e) {
      appRouter.goToLogin();
    }
  }

  Future<void> _handleAuthenticatedUser(User user) async {
    await _maybeImportGuestData(user);

    final pinCodeRepository = ref.read(pinCodeRepositoryProvider);
    final hasPinCode = await pinCodeRepository.isSetPinCode;
    if (hasPinCode) {
      appRouter.goToLoginByPinCode();
      return;
    }

    await _navigateAfterUnlock(user);
  }

  Future<void> _maybeImportGuestData(User user) async {
    if (user.role != UserRole.guest) {
      return;
    }

    final storage = await ref.read(simpleStorageProvider);
    final isCreatedGuestData = await storage.getBool(_isCreatedGuestData);
    if (isCreatedGuestData == true) {
      return;
    }

    try {
      final dataImportService = ref.read(dataImportServiceProvider);
      final result =
          await dataImportService.importFromAssetFile('assets/data/mock.jsonl');

      if (result.success) {
        // Show success message using the notification provider
        ref.read(notificationProvider.notifier).showSuccess(
              LKey.authGuestImportSuccess.tr(
                namedArgs: {
                  'success': '${result.successfulImports}',
                },
              ),
            );
      } else if (result.hasPartialSuccess) {
        // Show warning for partial success
        ref.read(notificationProvider.notifier).showWarning(
              LKey.authGuestImportPartial.tr(
                namedArgs: {
                  'success': '${result.successfulImports}',
                  'total': '${result.totalLines}',
                  'failed': '${result.failedImports}',
                },
              ),
            );
      } else {
        // Log errors but don't fail the login process
        for (final error in result.errors) {
          developer.log(
            'Data import error: $error',
            name: 'AuthController',
          );
        }
      }

      developer.log(
        'Data import completed: ${result.successfulImports}/${result.totalLines} products imported',
        name: 'AuthController',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to import guest data: $e',
        name: 'AuthController',
        error: e,
        stackTrace: stackTrace,
      );
    }

    await storage.saveBool(_isCreatedGuestData, true);
  }

  Future<void> _navigateAfterUnlock(User user) async {
    ref.read(sampleDataOnboardingProvider.notifier).state = false;

    final sampleDataPromptService =
        ref.read(adminSampleDataPromptServiceProvider);
    final shouldShowSampleData = await sampleDataPromptService.shouldShow(user);

    if (shouldShowSampleData) {
      ref.read(sampleDataOnboardingProvider.notifier).state = true;
      appRouter.replaceAll([const CreateSampleDataRoute()]);
      return;
    }

    appRouter.goHomeByRole(user.role);
  }

  Future<void> goToPostLoginDestination() async {
    final user = state.whenOrNull(
      authenticated: (user, DateTime? lastLogin) => user,
    );

    if (user == null) {
      appRouter.goToLogin();
      return;
    }

    await _navigateAfterUnlock(user);
  }

  Future<void> completeAdminSampleDataOnboarding() async {
    final user = state.whenOrNull(
      authenticated: (user, DateTime? lastLogin) => user,
    );

    if (user == null) {
      appRouter.goToLogin();
      return;
    }

    ref.read(sampleDataOnboardingProvider.notifier).state = false;
    await ref.read(adminSampleDataPromptServiceProvider).markCompleted(user);
    appRouter.goHomeByRole(user.role);
  }

  Future<AuthState> _loadAuthData() async {
    try {
      final prefs = ref.read(securityStorageProvider);
      final authState =
          await prefs.getObject(_authStateKey, AuthState.fromJson);

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
        username: LKey.authGuestName.tr(),
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
      notificationTitle: LKey.authRestartTitle.tr(),
      notificationBody: LKey.authRestartMessage.tr(),
    );
  }

  // Logout method
  Future<void> logout() async {
    ref.read(sampleDataOnboardingProvider.notifier).state = false;

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
        notificationTitle: LKey.authRestartTitle.tr(),
        notificationBody: LKey.authRestartMessage.tr(),
      );
    } else {
      state = const AuthState.unauthenticated();
      final prefs = ref.read(securityStorageProvider);
      await prefs.removeObject(_authStateKey);
      appRouter.goToLogin();
    }
  }
}

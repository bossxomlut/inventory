import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/index.dart';
import '../../../domain/repositories/index.dart';
import '../../../provider/index.dart';
import '../../../resources/string.dart';
import '../../../routes/app_router.dart';
import '../../../shared_widgets/user_access_blocked_dialog.dart';
import 'auth_provider.dart';

part 'login_provider.g.dart';

@riverpod
class LoginController extends _$LoginController with CommonProvider<LoginState> {
  @override
  LoginState build() {
    return const LoginState(
      userName: '',
      password: '',
    );
  }

  void login() async {
    //validate username/password
    final userName = state.userName;
    final password = state.password;

    showLoading();

    final authRepository = ref.read(authRepositoryProvider);

    authRepository.login(userName, password).then(
      (User value) async {
        // Check if user is active (only for regular users, admin can always login)
        if (value.role == UserRole.user && !value.isActive) {
          hideLoading();

          // Show blocked dialog for login
          final context = appRouter.navigatorKey.currentContext;
          if (context != null) {
            await UserAccessBlockedDialog.show(context, isRegistrationSuccess: false);
          }
          return;
        }

        //read authProvider
        final authProvider = ref.watch(authControllerProvider.notifier);

        await authProvider.login(id: value.id, username: value.username, role: value.role);

        hideLoading();

        await authProvider.goToPostLoginDestination();
      },
    ).onError(
      (error, StackTrace stackTrace) {
        log('Login error: $error', stackTrace: stackTrace);
        hideLoading();
        showError(LKey.loginValidateMessageUserAccount.tr());
      },
    );
  }

  void guestLogin() async {
    final authProvider = ref.watch(authControllerProvider.notifier);
    await authProvider.guestLogin();
  }

  void updateUserName(String userName) {
    state = state.copyWith(userName: userName);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }
}

//sign up user with role
@riverpod
class SignUpController extends _$SignUpController with CommonProvider<SignUpState> {
  @override
  SignUpState build() {
    return const SignUpState(
      userName: '',
      password: '',
      confirmPassword: '',
      role: UserRole.user,
      securityQuestionId: 1,
      securityAnswer: '',
      isExistAdmin: false,
    );
  }

  void checkExistAdmin() async {
    final authRepository = ref.read(authRepositoryProvider);
    authRepository.checkExistAdmin().then(
      (value) {
        state = state.copyWith(isExistAdmin: value);
      },
    );
  }

  void signUp() async {
    //check empty data
    if (state.userName.isEmpty || state.password.isEmpty) {
      showError(LKey.messageDefaultApiError);
      return;
    }

    //check if password and confirm password are same
    if (state.password != state.confirmPassword) {
      showError(LKey.signUpValidateMessagePasswordMatch.tr());
      return;
    }

    //validate username/password
    final userName = state.userName;
    final password = state.password;
    log('userName: $userName, password: $password');

    showLoading();

    final authRepository = ref.read(authRepositoryProvider);
    authRepository
        .register(
      userName,
      password,
      state.role,
      state.securityQuestionId,
      state.securityAnswer,
    )
        .then(
      (value) async {
        // Check if user is active (only for regular users, admin can always login)
        if (value.role == UserRole.user && !value.isActive) {
          hideLoading();

          // Show registration success dialog
          final context = appRouter.navigatorKey.currentContext;
          if (context != null) {
            await UserAccessBlockedDialog.show(context, isRegistrationSuccess: true);
          }
          return;
        }

        //read authProvider
        final authProvider = ref.read(authControllerProvider.notifier);

        await authProvider.login(id: value.id, username: value.username, role: value.role);

        hideLoading();

        await authProvider.goToPostLoginDestination();
      },
    ).onError(
      (error, StackTrace stackTrace) {
        hideLoading();
        showError(LKey.signUpValidateMessageUserAccount.tr());
      },
    );
  }

  void updateUserName(String userName) {
    state = state.copyWith(userName: userName);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void updateRole(UserRole role) {
    state = state.copyWith(role: role);
  }

  void updateSecurityQuestionId(int securityQuestionId) {
    state = state.copyWith(securityQuestionId: securityQuestionId);
  }

  void updateSecurityAnswer(String securityAnswer) {
    state = state.copyWith(securityAnswer: securityAnswer);
  }
}

@riverpod
class ForgotPasswordController extends _$ForgotPasswordController with CommonProvider<ForgotPasswordState> {
  @override
  ForgotPasswordState build() {
    return const ForgotPasswordState(
      userAccount: '',
      securityQuestionId: -1,
      securityAnswer: '',
      password: '',
      confirmPassword: '',
    );
  }

  Future<bool> checkInfo() async {
    final repository = ref.read(authRepositoryProvider);
    final userAccount = state.userAccount;
    final securityQuestionId = state.securityQuestionId;
    final securityAnswer = state.securityAnswer;

    //check data
    try {
      final isValidFromDb = await repository.checkSecurityQuestion(
        userAccount,
        securityQuestionId,
        securityAnswer,
      );

      if (isValidFromDb) {
        return true;
      } else {
        showError(LKey.loginUserNotFound.tr());
      }
    } catch (e) {
      showError(e.toString());
    }
    return false;
  }

  void setNewPassword() async {
    //check empty data
    if (state.password.isEmpty || state.confirmPassword.isEmpty) {
      showError(LKey.messageDefaultApiError);
      return;
    }

    //check if password and confirm password are same
    if (state.password != state.confirmPassword) {
      showError(LKey.signUpValidateMessagePasswordMatch.tr());
      return;
    }

    //validate username/password
    final userAccount = state.userAccount;
    final password = state.password;

    showLoading();

    final authRepository = ref.read(authRepositoryProvider);
    authRepository.updatePassword(userAccount, password).then(
      (value) async {
        hideLoading();
        appRouter.goToLogin();
      },
    ).onError(
      (error, StackTrace stackTrace) {
        hideLoading();
        showError(LKey.signUpValidateMessageUserAccount.tr());
      },
    );
  }

  void updateUserAccount(String userAccount) {
    state = state.copyWith(userAccount: userAccount);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void updateSecurityQuestionId(int securityQuestionId) {
    state = state.copyWith(securityQuestionId: securityQuestionId);
  }

  void updateSecurityAnswer(String securityAnswer) {
    state = state.copyWith(securityAnswer: securityAnswer);
  }
}

@riverpod
class ResetPasswordController extends _$ResetPasswordController with CommonProvider<ForgotPasswordState> {
  @override
  ForgotPasswordState build() {
    final authState = ref.watch(authControllerProvider);
    return authState.maybeWhen(
      orElse: () {
        return const ForgotPasswordState(
          userAccount: '',
          securityQuestionId: -1,
          securityAnswer: '',
          password: '',
          confirmPassword: '',
        );
      },
      authenticated: (User user, DateTime? lastLoginTime) {
        return ForgotPasswordState(
          userAccount: user.username,
          securityQuestionId: -1,
          securityAnswer: '',
          password: '',
          confirmPassword: '',
        );
      },
    );
  }

  Future<bool> checkInfo() async {
    final repository = ref.read(authRepositoryProvider);
    final userAccount = state.userAccount;
    final securityQuestionId = state.securityQuestionId;
    final securityAnswer = state.securityAnswer;
    log('userAccount: $userAccount, securityQuestionId: $securityQuestionId, securityAnswer: $securityAnswer');

    //check data
    try {
      final isValidFromDb = await repository.checkSecurityQuestion(
        userAccount,
        securityQuestionId,
        securityAnswer,
      );

      if (isValidFromDb) {
        return true;
      } else {
        showError(LKey.loginUserNotFound.tr());
      }
    } catch (e) {
      showError(e.toString());
    }
    return false;
  }

  void setNewPassword() async {
    //check empty data
    if (state.password.isEmpty || state.confirmPassword.isEmpty) {
      showError(LKey.messageDefaultApiError);
      return;
    }

    //check if password and confirm password are same
    if (state.password != state.confirmPassword) {
      showError(LKey.signUpValidateMessagePasswordMatch.tr());
      return;
    }

    //validate username/password
    final userAccount = state.userAccount;
    final password = state.password;

    showLoading();

    final authRepository = ref.read(authRepositoryProvider);
    authRepository.updatePassword(userAccount, password).then(
      (value) async {
        hideLoading();
        appRouter.popForced();
      },
    ).onError(
      (error, StackTrace stackTrace) {
        hideLoading();
        showError(LKey.signUpValidateMessageUserAccount.tr());
      },
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void updateSecurityQuestionId(int securityQuestionId) {
    state = state.copyWith(securityQuestionId: securityQuestionId);
  }

  void updateSecurityAnswer(String securityAnswer) {
    state = state.copyWith(securityAnswer: securityAnswer);
  }
}

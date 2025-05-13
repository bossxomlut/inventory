import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/index.dart';
import '../../../domain/repositories/index.dart';
import '../../../provider/index.dart';
import '../../../resources/string.dart';
import '../../../routes/app_router.dart';
import 'auth_provider.dart';

part 'login_provider.g.dart';

@riverpod
class LoginController extends _$LoginController with CommonProvider<LoginState> {
  @override
  LoginState build() {
    return LoginState(
      userName: '',
      password: '',
    );
  }

  void login() async {
    //validate username/password
    final userName = state.userName;
    final password = state.password;

    print('userName: $userName, password: $password');

    showLoading();

    final authRepository = ref.read(authRepositoryProvider);

    authRepository.login(userName, password).then(
      (User value) async {
        //read authProvider
        final authProvider = ref.read(authControllerProvider.notifier);

        await authProvider.login(id: value.id, username: value.username, role: value.role);

        hideLoading();

        appRouter.goHomeByRole(value.role);
      },
    ).onError(
      (error, StackTrace stackTrace) {
        hideLoading();
        showError(LKey.loginValidateMessageUserAccount.tr());
      },
    );
  }

  void updateUserName(String userName) {
    print('userName: $userName');
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
    return SignUpState(
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
    print('userName: $userName, password: $password');

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
        //read authProvider
        final authProvider = ref.read(authControllerProvider.notifier);

        await authProvider.login(id: value.id, username: value.username, role: value.role);

        hideLoading();

        appRouter.goHome();
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
    return ForgotPasswordState(
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
        showError('Not found');
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

    print('userAccount: $userAccount, password: $password');

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

  //
  // void login() async {
  //   //validate username/password
  //   final userName = state.userName;
  //   final password = state.password;
  //
  //   print('userName: $userName, password: $password');
  //
  //   showLoading();
  //
  //   final authRepository = ref.read(authRepositoryProvider);
  //
  //   authRepository.login(userName, password).then(
  //         (User value) async {
  //       //read authProvider
  //       final authProvider = ref.read(authControllerProvider.notifier);
  //
  //       await authProvider.login(id: value.id, username: value.username, role: value.role);
  //
  //       hideLoading();
  //
  //       appRouter.goHomeByRole(value.role);
  //     },
  //   ).onError(
  //         (error, StackTrace stackTrace) {
  //       hideLoading();
  //       showError(LKey.loginValidateMessageUserAccount.tr());
  //     },
  //   );
  // }

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

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/index.dart';
import '../../../provider/provider.dart';
import '../../../resources/string.dart';
import '../../../routes/app_router.dart';
import 'auth_provider.dart';

part 'login_provider.freezed.dart';
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
    print('userName: ${state.userName}');
    print('password: ${state.password}');
    final userName = state.userName;
    final password = state.password;

    showLoading();

    // await Future.delayed(const Duration(seconds: 2));

    final defaultUser = {
      'userName': 'admin',
      'password': 'admin',
    };

    if (userName != defaultUser['userName'] || password != defaultUser['password']) {
      hideLoading();
      showError(LKey.loginValidateMessageUserAccount.tr());
      return;
    }

    //read authProvider
    final authProvider = ref.read(authControllerProvider.notifier);

    await authProvider.login(id: '1', username: userName, role: UserRole.admin);

    hideLoading();

    appRouter.goHome();
  }

  void updateUserName(String userName) {
    state = state.copyWith(userName: userName);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }
}

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    required String userName,
    required String password,
  }) = _LoginState;
}

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    required String userName,
    required String password,
    required String confirmPassword,
    required UserRole role,
  }) = _SignUpState;
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
    );
  }

  void signUp() async {
    //check if password and confirm password are same
    if (state.password != state.confirmPassword) {
      showError(LKey.signUpValidateMessagePasswordMatch.tr());
      return;
    }

    //validate username/password
    print('userName: ${state.userName}');
    print('password: ${state.password}');

    final userName = state.userName;
    final password = state.password;

    showLoading();

    // await Future.delayed(const Duration(seconds: 2));

    final defaultUser = {
      'userName': 'admin',
      'password': 'admin',
    };

    if (userName == defaultUser['userName']) {
      hideLoading();
      showError(LKey.signUpValidateMessageUserAccount.tr());
      return;
    }

    //read authProvider
    final authProvider = ref.read(authControllerProvider.notifier);
    await authProvider.login(id: '1', username: userName, role: state.role);

    hideLoading();

    appRouter.goHome();
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
}

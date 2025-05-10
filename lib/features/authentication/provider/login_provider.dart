import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/index.dart';
import '../../../domain/repositories/index.dart';
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

        appRouter.goHome();
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
  }) = _SignUpState;
}

extension SignUpStateX on SignUpState {
  bool get isValid => userName.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty;
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
    authRepository.register(userName, password, state.role).then(
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
}

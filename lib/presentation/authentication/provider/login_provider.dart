import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../provider/provider.dart';

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

    showLoading();

    await Future.delayed(const Duration(seconds: 2));

    hideLoading();

    //call repository
    //set loading
    //show error message if any

    //show success message
    showSuccess('Login successful');

    //save user data in shared preferences

    //navigate to home page
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

enum UserRole {
  admin,
  user,
  guest,
}

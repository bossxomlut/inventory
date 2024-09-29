import 'package:injectable/injectable.dart';

import '../source/authentication_source.dart';
import 'authentication_repository.dart';

@Injectable(as: AuthenticationRepository)
class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl(this._authenticationSource);

  final AuthenticationSource _authenticationSource;

  @override
  Future login() {
    return Future.delayed(Duration(seconds: 2)).whenComplete(
      () => _authenticationSource
          .login(
        AuthCredentials(
          username: 'username',
          password: 'password',
        ),
      )
          .then(
        (String value) {
          print('value: $value');
        },
      ).onError(
        (error, StackTrace stackTrace) {
          print('error: $error');
        },
      ),
    );
  }
}

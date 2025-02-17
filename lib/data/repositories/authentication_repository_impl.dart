import 'package:injectable/injectable.dart';

import 'authentication_repository.dart';

@Injectable(as: AuthenticationRepository)
class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl();

  @override
  Future login() {
    throw UnimplementedError();
  }
}

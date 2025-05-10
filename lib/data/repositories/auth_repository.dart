import 'package:isar/isar.dart';

import '../../domain/index.dart';
import '../../domain/repositories/index.dart';
import '../model/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Isar _isar = Isar.getInstance()!;

  IsarCollection<UserCollection> get _collection => _isar.userCollections;

  @override
  Future<User> login(String account, String password) async {
    return _isar.txnSync(
      () {
        final foundUser = _collection.filter().accountEqualTo(account).passwordEqualTo(password).findFirstSync();

        if (foundUser == null) {
          throw Exception('Invalid credentials');
        }

        return User(
          id: foundUser.id.toString(),
          username: foundUser.account,
          role: UserRole.user,
        );
      },
    );
  }

  @override
  Future<User> register(String account, String password, UserRole role) async {
    //print('Registering user: $account, $password');

    print('Registering user: $account');
    print('Password: $password');

    return _isar.writeTxnSync(() {
      //find if user already exists
      final existingUser = _collection.filter().accountEqualTo(account).findFirstSync();

      if (existingUser != null) {
        throw Exception('User already exists');
      }

      final newUser = UserCollection()
        ..account = account
        ..password = password
        ..role = role.index;

      _collection.putSync(newUser);

      return User(
        id: newUser.id.toString(),
        username: newUser.account,
        role: UserRole.user,
      );
    });
  }

  @override
  Future<void> logout() async {}
}

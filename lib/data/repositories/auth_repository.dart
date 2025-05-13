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
          role: UserRole.values[foundUser.role],
        );
      },
    );
  }

  @override
  Future<User> register(
    String account,
    String password,
    UserRole role,
    int securityQuestionId,
    String securityQuestionAnswer,
  ) async {
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
        ..role = role.index
        ..securityQuestionId = securityQuestionId
        ..securityQuestionAnswer = securityQuestionAnswer;

      _collection.putSync(newUser);

      return User(
        id: newUser.id.toString(),
        username: newUser.account,
        role: role,
      );
    });
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> checkExistAdmin() {
    return _isar.txnSync(() async {
      final foundUser = _collection.filter().roleEqualTo(UserRole.admin.index).findFirstSync();
      return foundUser != null;
    });
  }

  @override
  Future<bool> checkSecurityQuestion(String account, int securityQuestionId, String answer) {
    return _isar.txnSync(() async {
      final foundUser = _collection
          .filter()
          .accountEqualTo(account)
          .securityQuestionIdEqualTo(securityQuestionId)
          .securityQuestionAnswerEqualTo(answer)
          .findFirstSync();

      return foundUser != null;
    });
  }

  @override
  Future<void> updatePassword(String account, String password) {
    return _isar.writeTxnSync(() async {
      final foundUser = _collection.filter().accountEqualTo(account).findFirstSync();

      if (foundUser == null) {
        throw NotFoundException('User not found');
      }

      foundUser.password = password;
      _collection.putSync(foundUser);
    });
  }
}

import 'package:isar/isar.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/index.dart';
import '../user/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Isar _isar = Isar.getInstance()!;

  IsarCollection<UserCollection> get _collection => _isar.userCollections;

  @override
  Future<User> login(String account, String password) async {
    return _isar.writeTxn(
      () async {
        final foundUser = await _collection.filter().accountEqualTo(account).and().passwordEqualTo(password).findFirst();

        if (foundUser == null) {
          throw Exception('Invalid credentials');
        }

        // Update last login time
        foundUser.lastLoginAt = DateTime.now();
        await _collection.put(foundUser);

        return User(
          id: foundUser.id,
          username: foundUser.account,
          role: UserRole.values[foundUser.role],
          isActive: foundUser.isActive,
          createdAt: foundUser.createdAt,
          lastLoginAt: foundUser.lastLoginAt,
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
    print('Registering user: $account');

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
        ..securityQuestionAnswer = securityQuestionAnswer
        ..isActive = (role == UserRole.admin) // Admin luôn active, user cần được kích hoạt
        ..createdAt = DateTime.now();

      _collection.putSync(newUser);

      return User(
        id: newUser.id,
        username: newUser.account,
        role: role,
        isActive: newUser.isActive,
        createdAt: newUser.createdAt,
      );
    });
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> checkExistAdmin() {
    return _isar.txn(() async {
      final foundUser = await _collection.filter().roleEqualTo(UserRole.admin.index).findFirst();
      return foundUser != null;
    });
  }

  @override
  Future<bool> checkSecurityQuestion(String account, int securityQuestionId, String answer) {
    return _isar.txn(() async {
      final foundUser = await _collection
          .filter()
          .accountEqualTo(account)
          .securityQuestionIdEqualTo(securityQuestionId)
          .securityQuestionAnswerEqualTo(answer)
          .findFirst();

      return foundUser != null;
    });
  }

  @override
  Future<void> updatePassword(String account, String password) {
    return _isar.writeTxn(() async {
      final foundUser = await _collection.filter().accountEqualTo(account).findFirst();

      if (foundUser == null) {
        throw NotFoundException('User not found');
      }

      foundUser.password = password;
      await _collection.put(foundUser);
    });
  }

  @override
  Future<List<User>> getAllUsers() async {
    return _isar.txn(() async {
      final users = await _collection.where().findAll();

      return users
          .map((userCollection) => User(
                id: userCollection.id,
                username: userCollection.account,
                role: UserRole.values[userCollection.role],
                isActive: userCollection.isActive,
                createdAt: userCollection.createdAt,
                lastLoginAt: userCollection.lastLoginAt,
              ))
          .toList();
    });
  }

  @override
  Future<void> toggleUserAccess(int userId, bool isActive) async {
    return _isar.writeTxn(() async {
      final user = await _collection.get(userId);

      if (user == null) {
        throw Exception('User not found');
      }

      user.isActive = isActive;
      await _collection.put(user);
    });
  }
}

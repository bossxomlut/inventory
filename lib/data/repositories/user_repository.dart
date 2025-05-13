import 'package:isar/isar.dart';

import '../../domain/entities/user/user.dart';
import '../../domain/repositories/index.dart';
import '../model/index.dart';

class UserRepositoryImpl extends UserRepository {
  final Isar _isar = Isar.getInstance()!;

  IsarCollection<UserCollection> get _collection => _isar.userCollections;

  @override
  Future<User> create(User item) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(User item) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<User>> getAll() {
    return _isar.txn(
      () {
        return _collection.where().findAll().then((List<UserCollection> value) {
          return value.map((e) {
            return User(
              id: e.id.toString(),
              username: e.account,
              role: UserRole.values[e.role],
            );
          }).toList();
        });
      },
    );
  }

  @override
  Future<User> read(int id) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<User> update(User item) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

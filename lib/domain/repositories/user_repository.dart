import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/user_repository.dart';
import '../index.dart';
import 'crud_repository.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(ref) => UserRepositoryImpl();

abstract class UserRepository implements CrudRepository<User, int>, GetAllRepository<User> {}

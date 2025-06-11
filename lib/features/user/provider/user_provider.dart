import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user/user.dart';
import '../../../domain/repositories/index.dart';
import '../../../provider/load_list.dart';

final loadUserProvider = AutoDisposeNotifierProvider<LoadUserController, LoadListState<User>>(() {
  return LoadUserController.new();
});

class LoadUserController extends LoadListController<User> {
  @override
  Future<LoadResult<User>> fetchData(LoadListQuery query) async {
    final userRepo = ref.watch(userRepositoryProvider);

    final roles = ref.watch(userRoleFilterProvider);

    return userRepo.getAll().then(
      (List<User> value) {
        return value.where((user) {
          if (roles.isEmpty) {
            return true;
          }
          return roles.contains(user.role);
        }).toList();
      },
    ).then(
      (List<User> value) {
        print('value: $value, search: ${query.search}');
        //search
        if (query.search != null && query.search!.isNotEmpty) {
          final list = value.where((user) {
            return user.username.toLowerCase().contains(query.search!.toLowerCase());
          }).toList();
          return LoadResult<User>(
            data: list,
            totalCount: list.length,
          );
        }

        return LoadResult<User>(
          data: value,
          totalCount: value.length,
        );
      },
    );
  }

  // Filter users by role
  Future<void> filterByRoles(Set<UserRole> roles) async {
    ref.read(userRoleFilterProvider.notifier).state = roles;
    loadData(
        query: LoadListQuery(
      page: 1,
      pageSize: 10,
      search: '',
    ));
  }
}

final userRoleFilterProvider = StateProvider<Set<UserRole>>((ref) => {});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user/user.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../shared_widgets/toast.dart';

// Provider để quản lý danh sách user
final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<User>>>((ref) {
  return UserListNotifier(ref);
});

// Provider để quản lý các action của user management
final userManagementProvider = StateNotifierProvider<UserManagementNotifier, AsyncValue<void>>((ref) {
  return UserManagementNotifier(ref);
});

class UserListNotifier extends StateNotifier<AsyncValue<List<User>>> {
  UserListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadUsers();
  }

  final Ref ref;
  List<User> _users = [];

  void _loadUsers() async {
    state = const AsyncValue.loading();
    
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final users = await authRepository.getAllUsers();
      _users = users;
      state = AsyncValue.data(_users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refreshUsers() {
    _loadUsers();
  }

  void updateUser(User updatedUser) {
    final updatedUsers = _users.map((user) {
      return user.id == updatedUser.id ? updatedUser : user;
    }).toList();
    
    _users = updatedUsers;
    state = AsyncValue.data(_users);
  }
}

class UserManagementNotifier extends StateNotifier<AsyncValue<void>> {
  UserManagementNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> toggleUserAccess(int userId, bool isActive) async {
    state = const AsyncValue.loading();
    
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.toggleUserAccess(userId, isActive);
      
      // Update user in the list
      final userListNotifier = ref.read(userListProvider.notifier);
      final currentUsers = ref.read(userListProvider).value ?? [];
      
      final userIndex = currentUsers.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        final updatedUser = currentUsers[userIndex].copyWith(isActive: isActive);
        userListNotifier.updateUser(updatedUser);
      }
      
      state = const AsyncValue.data(null);
      
      // Show success message
      showSuccess(
        message: isActive 
          ? 'Đã kích hoạt tài khoản người dùng thành công'
          : 'Đã khóa tài khoản người dùng thành công'
      );
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Show error message
      showError(
        message: 'Có lỗi xảy ra khi ${isActive ? 'kích hoạt' : 'khóa'} tài khoản: ${error.toString()}'
      );
    }
  }

  Future<void> deleteUser(int userId) async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate API call - In real implementation, add delete method to repository
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      // Remove user from the list
      final userListNotifier = ref.read(userListProvider.notifier);
      userListNotifier.refreshUsers(); // Refresh the entire list
      
      state = const AsyncValue.data(null);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

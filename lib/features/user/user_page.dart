import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

import '../../domain/entities/user/user.dart';
import '../../provider/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import 'provider/user_management_provider.dart';

@RoutePage()
class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userListProvider);
    final theme = context.appTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quản lý người dùng',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(userListProvider),
            tooltip: 'Làm mới danh sách',
          ),
        ],
      ),
      body: users.when(
        data: (userList) {
          final regularUsers =
              userList.where((user) => user.role == UserRole.user).toList();

          return Column(
            children: [
              // Header thống kê
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: theme.colorPrimary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: theme.colorPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng số người dùng: ${regularUsers.length}',
                            style: theme.textMedium16Default,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hoạt động: ${regularUsers.where((u) => u.isActive).length} | '
                            'Bị khóa: ${regularUsers.where((u) => !u.isActive).length}',
                            style: theme.textRegular14Subtle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Danh sách người dùng
              Expanded(
                child: regularUsers.isEmpty
                    ? const UserEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: regularUsers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = regularUsers[index];
                          return UserCard(user: user);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorError,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải danh sách người dùng',
                style: theme.textMedium16Default,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textRegular14Subtle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userListProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserEmptyState extends StatelessWidget {
  const UserEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có người dùng nào',
              style: theme.textMedium16Default.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Danh sách người dùng sẽ xuất hiện ở đây sau khi họ đăng ký tài khoản.',
              style: theme.textRegular14Subtle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Người dùng mới đăng ký sẽ cần được admin kích hoạt trước khi có thể sử dụng ứng dụng.',
              style: theme.textRegular14Sublest,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorPrimary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Hướng dẫn người dùng đăng ký tài khoản để bắt đầu sử dụng',
                      style: theme.textRegular12Default.copyWith(
                        color: theme.colorPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCard extends ConsumerWidget {
  const UserCard({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final managementState = ref.watch(userManagementProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar với trạng thái
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: user.isActive ? Colors.green : Colors.grey,
                    child: Text(
                      user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: user.isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        user.isActive ? Icons.check : Icons.close,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Thông tin user
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.username,
                            style: theme.textMedium16Default.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: user.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isActive ? 'Hoạt động' : 'Bị khóa',
                            style: theme.textRegular12Default.copyWith(
                              color: user.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${user.id}',
                          style: theme.textRegular14Subtle,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.role.displayName,
                          style: theme.textRegular14Subtle,
                        ),
                      ],
                    ),
                    if (user.lastLoginAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đăng nhập cuối: ${_formatDateTime(user.lastLoginAt!)}',
                            style: theme.textRegular12Sublest,
                          ),
                        ],
                      ),
                    ],
                    if (user.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tạo: ${_formatDateTime(user.createdAt!)}',
                            style: theme.textRegular12Sublest,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nút quản lý trạng thái
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: managementState.isLoading
                      ? null
                      : () {
                          _showToggleConfirmDialog(
                              context, ref, user, !user.isActive);
                        },
                  icon: managementState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          user.isActive ? Icons.block : Icons.check_circle,
                          size: 18,
                        ),
                  label: Text(
                    user.isActive ? 'Khóa tài khoản' : 'Kích hoạt tài khoản',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.isActive
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    foregroundColor: user.isActive ? Colors.red : Colors.green,
                    elevation: 0,
                    side: BorderSide(
                      color: user.isActive
                          ? Colors.red.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (user.role == UserRole.user) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: user.isActive
                        ? () {
                            appRouter.goToUserPermission(user);
                          }
                        : null,
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Phân quyền'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showToggleConfirmDialog(
      BuildContext context, WidgetRef ref, User user, bool newValue) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              newValue ? Icons.check_circle : Icons.block,
              color: newValue ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(newValue ? 'Kích hoạt tài khoản' : 'Khóa tài khoản'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: user.isActive ? Colors.green : Colors.grey,
                    child: Text(
                      user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ID: ${user.id}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              newValue
                  ? 'Bạn có chắc muốn kích hoạt quyền truy cập cho người dùng này? '
                      'Sau khi kích hoạt, người dùng sẽ có thể đăng nhập vào ứng dụng.'
                  : 'Bạn có chắc muốn khóa quyền truy cập cho người dùng này? '
                      'Người dùng sẽ không thể đăng nhập vào ứng dụng cho đến khi được kích hoạt lại.',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(userManagementProvider.notifier)
                  .toggleUserAccess(user.id, newValue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newValue ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              newValue ? 'Kích hoạt' : 'Khóa',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

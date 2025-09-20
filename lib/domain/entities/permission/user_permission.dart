import 'permission.dart';

class UserPermission {
  const UserPermission({
    required this.id,
    required this.userId,
    required this.key,
    required this.isEnabled,
  });

  final int id;
  final int userId;
  final PermissionKey key;
  final bool isEnabled;

  UserPermission copyWith({
    int? id,
    int? userId,
    PermissionKey? key,
    bool? isEnabled,
  }) {
    return UserPermission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      key: key ?? this.key,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

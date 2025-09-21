import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

import '../../domain/entities/permission/permission.dart';
import '../../domain/entities/user/user.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import 'provider/user_permission_controller.dart';

@RoutePage()
class UserPermissionPage extends ConsumerWidget {
  const UserPermissionPage({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync =
        ref.watch(userPermissionControllerProvider(user.id));
    final notifier =
        ref.read(userPermissionControllerProvider(user.id).notifier);
    final defaultPermissions =
        PermissionCatalog.defaultPermissionsForUserRole(UserRole.user);
    final groupDefinitions = PermissionCatalog.groupedDefinitions();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Phân quyền: ${user.username}',
        actions: [
          TextButton(
            onPressed: permissionsAsync.isLoading
                ? null
                : () async {
                    await notifier.resetToDefault();
                    showSuccess(
                        message:
                            'Đã khôi phục quyền mặc định cho ${user.username}');
                  },
            child: const Text(
              'Khôi phục mặc định',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: permissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber,
                    size: 40, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  'Không thể tải quyền truy cập',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(userPermissionControllerProvider(user.id)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (permissions) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quyền mặc định',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Các quyền mặc định dành cho người dùng mới: ${defaultPermissions.length} quyền.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bạn có thể bật/tắt từng quyền bên dưới. Các quyền bị tắt sẽ ẩn tính năng tương ứng trong ứng dụng.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final group in PermissionGroupId.values)
                if (groupDefinitions[group] != null)
                  _PermissionGroupSection(
                    group: group,
                    definitions: groupDefinitions[group]!,
                    permissions: permissions,
                    defaults: defaultPermissions,
                    onToggle: (key, enabled) =>
                        notifier.togglePermission(key, enabled),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _PermissionGroupSection extends StatefulWidget {
  const _PermissionGroupSection({
    required this.group,
    required this.definitions,
    required this.permissions,
    required this.defaults,
    required this.onToggle,
  });

  final PermissionGroupId group;
  final List<PermissionDefinition> definitions;
  final Set<PermissionKey> permissions;
  final Set<PermissionKey> defaults;
  final void Function(PermissionKey key, bool enabled) onToggle;

  @override
  State<_PermissionGroupSection> createState() => _PermissionGroupSectionState();
}

class _PermissionGroupSectionState extends State<_PermissionGroupSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final enabledCount = widget.definitions
        .where((definition) => widget.permissions.contains(definition.key))
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          widget.group.icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          widget.group.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '$enabledCount/${widget.definitions.length} quyền',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: widget.definitions
            .map(
              (definition) => SwitchListTile.adaptive(
                value: widget.permissions.contains(definition.key),
                title: Text(definition.title),
                subtitle: definition.description == null
                    ? null
                    : Text(
                        definition.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                secondary: widget.defaults.contains(definition.key)
                    ? const Icon(Icons.star, color: Colors.amber, size: 18)
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onChanged: (enabled) => widget.onToggle(definition.key, enabled),
              ),
            )
            .toList(),
      ),
    );
  }
}

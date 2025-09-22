import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_banner_widget.dart';
import '../../core/helpers/scaffold_utils.dart';
import '../../domain/entities/permission/permission.dart';
import '../../domain/index.dart';
import '../../provider/permissions.dart';
import '../../provider/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/button/bottom_button_bar.dart';
import '../authentication/provider/auth_provider.dart';
import 'menu_manager.dart';
import 'provider/menu_group_order_provider.dart';

@RoutePage()
class HomePage2 extends ConsumerWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final theme = context.appTheme;
    return user.when(
        authenticated: (User user, DateTime? lastLoginTime) {
          final permissionsAsync = ref.watch(currentUserPermissionsProvider);

          return permissionsAsync.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Scaffold(
              body: Center(
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('$error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.refresh(currentUserPermissionsProvider),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (grantedPermissions) {
              final menuOrderState = ref.watch(menuGroupOrderControllerProvider);
              final preferredOrder = menuOrderState.value;
              final menuGroups = MenuManager.getMenuGroups(
                user: user,
                permissions: grantedPermissions,
                preferredOrder: preferredOrder,
              );

              if (menuGroups.isEmpty) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Tài khoản của bạn chưa được cấp quyền truy cập tính năng nào. Vui lòng liên hệ quản trị viên.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Scaffold(
                backgroundColor: Colors.white,
                bottomNavigationBar:
                    const SafeArea(child: AdBannerSmallWidget()),
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Modern header with greeting
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorPrimary.withOpacity(0.08),
                                    theme.colorPrimary.withOpacity(0.03),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorPrimary.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorPrimary,
                                          theme.colorPrimary.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorPrimary
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Xin chào,',
                                          style: theme.textRegular14Sublest,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.username,
                                          style: theme.headingSemibold20Default,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (menuGroups.length > 1)
                                        _buildHeaderIcon(
                                          context,
                                          icon: Icons.swap_vert,
                                          tooltip: 'Sắp xếp nhóm menu',
                                          onTap: () =>
                                              _openMenuReorderSheet(context, ref, menuGroups),
                                        ),
                                      const SizedBox(width: 12),
                                      _buildHeaderIcon(
                                        context,
                                        icon: Icons.settings_outlined,
                                        tooltip: 'Cài đặt',
                                        onTap: () {
                                          appRouter.goToSetting();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ]),
                        ),
                      ),
                      SliverList.separated(
                        itemBuilder: (BuildContext context, int groupIdx) {
                          final group = menuGroups[groupIdx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, bottom: 10),
                                  child: Text(
                                    group.title,
                                    style: theme.headingSemibold20Primary,
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.3,
                                  ),
                                  itemCount: group.items.length,
                                  itemBuilder: (context, index) {
                                    final item = group.items[index];
                                    return InkWell(
                                      onTap: item.destinationCallback,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorBackground,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: theme.colorBorderSublest,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorPrimary
                                                  .withOpacity(0.06),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.02),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      theme.colorPrimary
                                                          .withOpacity(0.1),
                                                      theme.colorPrimary
                                                          .withOpacity(0.05),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: theme.colorPrimary
                                                        .withOpacity(0.1),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  item.icon,
                                                  size: 24,
                                                  color: theme.colorPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Flexible(
                                                child: FittedBox(
                                                  child: Text(
                                                    item.title,
                                                    style: theme
                                                        .textMedium16Default,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 12,
                        ),
                        itemCount: menuGroups.length,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        unauthenticated: () => Scaffold(
              appBar: AppBar(
                title: const Text('Quản lý kho'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vui lòng đăng nhập để sử dụng ứng dụng.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        appRouter.goToLogin();
                      },
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
        initial: () => const SizedBox());
  }

  Widget _buildHeaderIcon(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final theme = context.appTheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorBorderSublest,
          width: 1,
        ),
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: theme.colorIcon, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Future<void> _openMenuReorderSheet(
    BuildContext context,
    WidgetRef ref,
    List<MenuGroup> groups,
  ) async {
    final controller = ref.read(menuGroupOrderControllerProvider.notifier);
    final initialOrder = groups.map((group) => group.id).toList();

    final result = await showModalBottomSheet<List<MenuGroupId>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var tempOrder = List<MenuGroupId>.from(initialOrder);
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.swap_vert, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sắp xếp nhóm chức năng',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kéo thả để ưu tiên nhóm hiển thị. Cài đặt chỉ áp dụng cho tài khoản hiện tại.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: listEquals(tempOrder, initialOrder)
                              ? null
                              : () {
                                  setState(() {
                                    tempOrder =
                                        List<MenuGroupId>.from(initialOrder);
                                  });
                                },
                          icon: const Icon(Icons.undo),
                          label: const Text('Hoàn tác'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await controller.reset();
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Mặc định'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          buildDefaultDragHandles: false,
                          shrinkWrap: true,
                          itemCount: tempOrder.length,
                          itemBuilder: (context, index) {
                            final id = tempOrder[index];
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(id),
                              index: index,
                              child: Card(
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Icon(
                                          Icons.drag_indicator,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              MenuManager.titleFor(id),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Vị trí hiện tại: ${index + 1}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.reorder,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = tempOrder.removeAt(oldIndex);
                              tempOrder.insert(newIndex, item);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BottomButtonBar(
                      padding: const EdgeInsets.only(top: 12),
                      onCancel: () {
                        Navigator.of(sheetContext).pop();
                      },
                      onSave: () {
                        Navigator.of(sheetContext).pop(tempOrder);
                      },
                      cancelButtonText: 'Đóng',
                      saveButtonText: 'Lưu',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      await controller.saveOrder(result);
    }
  }
}

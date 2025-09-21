import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../domain/entities/check/check_session.dart';
import '../../../provider/load_list.dart';
import '../../../shared_widgets/index.dart';
import '../../core/index.dart';
import '../../domain/index.dart';
import '../../provider/index.dart';
import '../../routes/app_router.dart';
import 'provider/check_session_provider.dart';
import 'widget/create_session_bottom_sheet.dart';

@RoutePage()
class CheckSessionsPage extends HookConsumerWidget {
  const CheckSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final isMounted = useIsMounted();
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
                const Icon(Icons.warning_amber, size: 40, color: Colors.redAccent),
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
                  onPressed: () => ref.refresh(currentUserPermissionsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (permissions) {
        final canViewSessions = permissions.contains(PermissionKey.inventoryView);
        final canCreateSession = permissions.contains(PermissionKey.inventoryCreateSession);

        if (!canViewSessions) {
          return const Scaffold(
            appBar: CustomAppBar(title: 'Phiên kiểm kê'),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bạn không có quyền xem danh sách phiên kiểm kê.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        Future<void> createNewSession() async {
          if (!canCreateSession) {
            return;
          }

          final result = await CreateSessionBottomSheet().show(context);
          if (result != null) {
            try {
              final sessionNotifier = ref.read(loadCheckSessionProvider(ActiveViewType.active).notifier);
              final createdSession = await sessionNotifier.createCheckSession(result);

              if (createdSession != null && isMounted()) {
                appRouter.push(CheckRoute(session: createdSession));
              }
            } catch (e) {
              if (isMounted()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi tạo phiên: $e')),
                );
              }
            }
          }
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Phiên kiểm kê',
            bottom: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Đang hoạt động', icon: Icon(Icons.pending_actions)),
                Tab(text: 'Đã hoàn thành', icon: Icon(Icons.done_all)),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              ActiveSessionPage(canManage: canCreateSession),
              DoneSessionPage(canManage: canCreateSession),
            ],
          ),
          floatingActionButton: canCreateSession
              ? FloatingActionButton(
                  onPressed: createNewSession,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}

class SessionCard extends ConsumerWidget {
  final CheckSession session;
  final bool canManage;

  const SessionCard(
    this.session, {
    super.key,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    return InkWell(
      onTap: () {
        appRouter.push(CheckRoute(session: session));
      },
      child: Container(
        decoration: getCardDecoration(context),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(
              HugeIcons.strokeRoundedProductLoading,
              color: Colors.green[600],
            ),
          ),
          title: Text(
            session.name,
            style: theme.textMedium16Default,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Kiểm kê bởi: ${session.createdBy}',
                style: theme.textRegular13Default,
              ),
              const SizedBox(height: 2),
              Text(
                'Ngày: ${session.startDate.timeAgo}',
                style: theme.textRegular13Default,
              ),
            ],
          ),
          trailing: session.status != CheckSessionStatus.inProgress || !canManage
              ? null
              : PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red[300]),
                          const SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red[300])),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (action) {
                    if (action == 'delete') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: const Text('Bạn có chắc chắn muốn xóa phiên kiểm kê này?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  final notifier = ref.read(loadCheckSessionProvider(ActiveViewType.active).notifier);
                                  notifier.deleteCheckSession(session);
                                },
                                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }

  Decoration getCardDecoration(BuildContext context) {
    switch (session.status) {
      case CheckSessionStatus.inProgress:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              Colors.green[500]!,
              Colors.green[400]!,
              Colors.green[300]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case CheckSessionStatus.completed:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        );
    }
  }
}

class ActiveSessionPage extends HookConsumerWidget {
  const ActiveSessionPage({
    super.key,
    required this.canManage,
  });

  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(loadCheckSessionProvider(ActiveViewType.active));

    useEffect(() {
      Future.microtask(() {
        // Load initial data
        ref.read(loadCheckSessionProvider(ActiveViewType.active).notifier).init();
      });
      return null;
    }, []);

    if (activeSession.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeSession.hasError) {
      return Center(child: Text('Lỗi: ${activeSession.error}'));
    }

    if (activeSession.isEmpty) {
      return const Center(
        child: Text('Không có phiên kiểm kê nào đang hoạt động'),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (BuildContext context, int index) {
        return SessionCard(
          activeSession.data[index],
          canManage: canManage,
        );
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
      itemCount: activeSession.length,
    );
  }
}

class DoneSessionPage extends HookConsumerWidget {
  const DoneSessionPage({
    super.key,
    required this.canManage,
  });

  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(loadCheckSessionProvider(ActiveViewType.done));

    useEffect(() {
      Future.microtask(() {
        // Load initial data
        ref.read(loadCheckSessionProvider(ActiveViewType.done).notifier).init();
      });
      return null;
    }, []);

    if (activeSession.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeSession.hasError) {
      return Center(child: Text('Lỗi: ${activeSession.error}'));
    }

    if (activeSession.isEmpty) {
      return const Center(
        child: Text('Không có phiên kiểm kê nào đang hoạt động'),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (BuildContext context, int index) {
        return SessionCard(
          activeSession.data[index],
          canManage: canManage,
        );
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
      itemCount: activeSession.length,
    );
  }
}

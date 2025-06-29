import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../domain/entities/check/check_session.dart';
import '../../../domain/entities/get_id.dart';
import '../../../provider/load_list.dart';
import '../../../routes/app_router.dart';
import '../../../shared_widgets/index.dart';
import '../../domain/entities/check/check.dart';
import 'provider/check_session_provider.dart';
import 'widget/create_session_bottom_sheet.dart';

@RoutePage()
class CheckSessionsPage extends HookConsumerWidget {
  const CheckSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final isMounted = useIsMounted();

    void createNewSession() async {
      final result = await CreateSessionBottomSheet().show(context);
      //
      if (result != null) {
        try {
          final sessionNotifier = ref.read(loadCheckSessionProvider(ActiveViewType.active).notifier);
          sessionNotifier.createCheckSession(
            CheckSession(
              id: undefinedId,
              name: result['name']!,
              startDate: DateTime.now(),
              createdBy: result['createdBy']!,
              checkedBy: result['checkedBy']!, // Thêm người kiểm kê
              status: CheckSessionStatus.inProgress, // Sửa thành "Đang thực hiện" thay vì "Hoàn thành"
              checks: [],
              note: result['notes']!.isNotEmpty ? result['notes'] : null,
            ),
          );
        } catch (e) {
          if (isMounted()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tạo phiên: $e')),
            );
          }
        }
      }
    }

    // Main widget build
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
        children: const [
          ActiveSessionPage(),
          DoneSessionPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewSession,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget buildSessionCard(CheckSession session) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 2), // changes position of shadow
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
    ),
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
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tạo bởi: ${session.createdBy}'),
          Text('Kiểm kê bởi: ${session.checkedBy}'),
          Text('Ngày: ${session.startDate.toString()}'),
          Text(
            'Trạng thái: ${session.status.name}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          if (session.status != CheckSessionStatus.completed)
            PopupMenuItem(
              value: 'continue',
              child: const Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Tiếp tục'),
                ],
              ),
            ),
          PopupMenuItem(
            value: 'view',
            child: const Row(
              children: [
                Icon(Icons.visibility),
                SizedBox(width: 8),
                Text('Xem chi tiết'),
              ],
            ),
          ),
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
          if (action == 'continue') {
            appRouter.push(CheckRoute(session: session));
          } else if (action == 'view') {
            // TODO: Implement view details
          } else if (action == 'delete') {
            // TODO: Implement delete session
          }
        },
      ),
    ),
  );
}

class ActiveSessionPage extends HookConsumerWidget {
  const ActiveSessionPage({super.key});

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
        return buildSessionCard(activeSession.data[index]);
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
      itemCount: activeSession.length,
    );
  }
}

class DoneSessionPage extends HookConsumerWidget {
  const DoneSessionPage({super.key});

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
        return buildSessionCard(activeSession.data[index]);
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
      itemCount: activeSession.length,
    );
  }
}

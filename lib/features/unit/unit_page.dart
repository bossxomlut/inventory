import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/index.dart';
import '../../provider/index.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/index.dart';
import 'add_unit.dart';
import 'provider/unit_filter_provider.dart';
import 'provider/unit_provider.dart';
import 'unit_card.dart';

@RoutePage()
class UnitPage extends HookConsumerWidget {
  const UnitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void initData() {
      ref.read(loadUnitProvider.notifier).refresh();
    }

    useEffect(() {
      Future(initData);
    }, const []);

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
                  onPressed: () => ref.refresh(currentUserPermissionsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (permissions) {
        final theme = context.appTheme;
        final units = ref.watch(loadUnitProvider);
        final canView = permissions.contains(PermissionKey.unitView);
        final canCreate = permissions.contains(PermissionKey.unitCreate);
        final canUpdate = permissions.contains(PermissionKey.unitUpdate);
        final canDelete = permissions.contains(PermissionKey.unitDelete);

        if (!canView) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Đơn vị'),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bạn không có quyền xem danh sách đơn vị.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (!canDelete) {
          final multiState = ref.read(multiSelectUnitProvider);
          if (multiState.enable || multiState.data.isNotEmpty) {
            ref.read(multiSelectUnitProvider.notifier).disableAndClear();
          }
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final multiState = ref.watch(multiSelectUnitProvider);
                final enable = canDelete && multiState.enable;
                final isNotEmpty = multiState.data.isNotEmpty;

                return CustomAppBar(
                  title: 'Đơn vị',
                  leading: enable
                      ? IconButton(
                          onPressed: () {
                            ref
                                .read(multiSelectUnitProvider.notifier)
                                .disableAndClear();
                          },
                          icon: Icon(Icons.close,
                              color: Colors.white, size: 24.0),
                        )
                      : AppBackButton(),
                  actions: [
                    if (enable && canDelete)
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                        ),
                        color: Colors.white,
                        onPressed: isNotEmpty
                            ? () {
                                ref
                                    .read(loadUnitProvider.notifier)
                                    .removeMultipleUnits();
                              }
                            : null,
                      ),
                    if (!enable && canDelete)
                      IconButton(
                        icon: Text(
                          'Chọn',
                          style: theme.textMedium13Default.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (enable) {
                            ref
                                .read(multiSelectUnitProvider.notifier)
                                .disable();
                          } else {
                            ref.read(multiSelectUnitProvider.notifier).enable();
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          body: Builder(
            builder: (BuildContext context) {
              if (units.hasError) {
                return Center(child: Text('Lỗi: ${units.error}'));
              } else if (units.data.isEmpty) {
                return const Center(child: Text('Không tìm thấy đơn vị nào.'));
              }

              return ListView.builder(
                itemCount: units.data.length,
                itemBuilder: (context, index) {
                  return ProviderScope(
                    overrides: [
                      currentIndexProvider.overrideWithValue(index),
                      currentUnitProvider.overrideWithValue(units.data[index]),
                    ],
                    child: OptimizedUnitCard(
                      canEdit: canUpdate,
                      canToggleSelection: canDelete,
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: canCreate
              ? FloatingActionButton(
                  onPressed: () {
                    AddUnit().show(context);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/index.dart';
import '../../provider/index.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/index.dart';
import 'add_category.dart';
import 'category_card.dart';
import 'provider/category_provider.dart';

@RoutePage()
class CategoryPage extends HookConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void initData() {
      ref.read(loadCategoryProvider.notifier).refresh();
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
        final canView = permissions.contains(PermissionKey.categoryView);
        if (!canView) {
          return const Scaffold(
            appBar: CustomAppBar(title: 'Danh mục'),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bạn không có quyền xem danh sách danh mục.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final canCreate = permissions.contains(PermissionKey.categoryCreate);
        final canUpdate = permissions.contains(PermissionKey.categoryUpdate);
        final canDelete = permissions.contains(PermissionKey.categoryDelete);

        if (!canDelete) {
          final multiState = ref.read(multiSelectCategoryProvider);
          if (multiState.enable || multiState.data.isNotEmpty) {
            ref.read(multiSelectCategoryProvider.notifier).disableAndClear();
          }
        }

        final categories = ref.watch(loadCategoryProvider);
        final theme = context.appTheme;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final multiState = ref.watch(multiSelectCategoryProvider);
                final enable = canDelete && multiState.enable;
                final isNotEmpty = multiState.data.isNotEmpty;

                return CustomAppBar(
                  title: 'Danh mục',
                  leading: enable
                      ? IconButton(
                          onPressed: () {
                            ref.read(multiSelectCategoryProvider.notifier).disableAndClear();
                          },
                          icon: Icon(Icons.close, color: Colors.white, size: 24.0),
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
                                ref.read(loadCategoryProvider.notifier).removeMultipleCategories();
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
                            ref.read(multiSelectCategoryProvider.notifier).disable();
                          } else {
                            ref.read(multiSelectCategoryProvider.notifier).enable();
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
              if (categories.hasError) {
                return Center(child: Text('Lỗi: ${categories.error}'));
              } else if (categories.data.isEmpty) {
                return const Center(child: Text('Không tìm thấy danh mục nào.'));
              }

              return ListView.builder(
                itemCount: categories.data.length,
                itemBuilder: (context, index) {
                  return ProviderScope(
                    overrides: [
                      currentIndexProvider.overrideWithValue(index),
                      currentCategoryProvider.overrideWithValue(categories.data[index]),
                    ],
                    child: OptimizedCategoryCard(
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
                    AddCategory().show(context);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      ref.read(categoryProvider.notifier).refresh();
    }

    useEffect(() {
      Future(initData);
    }, const []);

    final categories = ref.watch(categoryProvider);

    final theme = context.appTheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final multiState = ref.watch(multiSelectCategoryProvider);
            final enable = multiState.enable;
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
                if (enable)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                    ),
                    color: Colors.white,
                    onPressed: isNotEmpty
                        ? () {
                            ref.read(categoryProvider.notifier).removeMultipleCategories();
                          }
                        : null,
                  ),
                if (!enable)
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
                child: const OptimizedCategoryCard(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddCategory().show(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

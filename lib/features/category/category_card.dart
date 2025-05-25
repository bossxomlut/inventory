import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/index.dart';
import '../../domain/index.dart';
import '../../provider/index.dart';
import 'add_category.dart';
import 'provider/category_provider.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.color,
    this.onTap,
  });

  final Category category;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return ListTile(
      minTileHeight: 68,
      leading: CircleAvatar(
        backgroundColor: category.name.backgroundColorFromString,
        child: Text(
          category.name.twoFirstLetters,
          style: theme.textMedium15Default.copyWith(
            color: category.name.colorTextStyle,
          ),
        ),
      ),
      title: Text(category.name, style: theme.textMedium16Default),
      subtitle: category.description.isNullOrEmpty
          ? null
          : Text(category.description ?? '', style: theme.textRegular14Subtle),
      onTap: onTap,
      tileColor: color,
    );
  }
}

class OptimizedCategoryCard extends ConsumerWidget {
  const OptimizedCategoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.read(currentIndexProvider);
    final category = ref.watch(currentCategoryProvider);
    // final category = ref.watch(categoryProvider.select((value) => value.data[index]));

    print('build ngooài ${index}');
    return Stack(
      children: [
        CategoryCard(
          category: category,
          color: index.color,
          onTap: () {
            AddCategory(category: category).show(context);
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              print('build bên trong ${index}');
              final enable = ref.watch(multiSelectCategoryProvider.select((value) => value.enable));
              if (!enable) {
                return const SizedBox.shrink();
              }

              return Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  print('build checkbox ${index}');
                  final isSelected =
                      ref.watch(multiSelectCategoryProvider.select((value) => value.data.contains(category)));
                  return Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      ref.read(multiSelectCategoryProvider.notifier).toggle(category);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

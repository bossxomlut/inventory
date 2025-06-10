import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../category/provider/category_provider.dart';
import '../provider/product_filter_provider.dart';

class ProductFilterDrawer extends ConsumerWidget {
  const ProductFilterDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortType = ref.watch(productSortTypeProvider);
    final categoryFilter = ref.watch(productCategoryFilterProvider);
    final categories = ref.watch(allCategoriesProvider);
    final theme = Theme.of(context);

    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc sản phẩm',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),

              // Sort section
              Text(
                'Sắp xếp theo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: ProductSortType.values.map((type) {
                  final isSelected = sortType == type;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(type.displayName),
                    onSelected: (_) {
                      ref.read(productSortTypeProvider.notifier).state = type;
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primaryContainer,
                    checkmarkColor: theme.colorScheme.primary,
                    avatar: Icon(
                      type.icon,
                      size: 18,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Category filter section
              Text(
                'Lọc theo danh mục',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              categories.when(
                  data: (List<Category> data) {
                    if (data.isEmpty) {
                      return const Text('Không có danh mục nào');
                    }
                    return Wrap(spacing: 8, children: [
                      FilterChip(
                        selected: categoryFilter == null,
                        label: const Text('Tất cả'),
                        onSelected: (_) {
                          ref.read(productCategoryFilterProvider.notifier).state = null;
                        },
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                      ),
                      ...data.map((category) {
                        final isSelected = categoryFilter?.id == category.id;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(category.name),
                          onSelected: (_) {
                            ref.read(productCategoryFilterProvider.notifier).state = isSelected ? null : category;
                          },
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primaryContainer,
                          checkmarkColor: theme.colorScheme.primary,
                        );
                      }).toList(),
                    ]);
                  },
                  error: (Object error, StackTrace stackTrace) {
                    return Text(
                      'Lỗi tải danh mục: $error',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                    );
                  },
                  loading: () => CircularProgressIndicator()),

              //
              // if (categories.isEmpty)
              //   const Text('Không có danh mục nào')
              // else
              //   Wrap(
              //     spacing: 8,
              //     children: [
              //       FilterChip(
              //         selected: categoryFilter == null,
              //         label: const Text('Tất cả'),
              //         onSelected: (_) {
              //           ref.read(productCategoryFilterProvider.notifier).state = null;
              //         },
              //         backgroundColor: theme.colorScheme.surface,
              //         selectedColor: theme.colorScheme.primaryContainer,
              //         checkmarkColor: theme.colorScheme.primary,
              //       ),
              //       ...categories.map((category) {
              //         final isSelected = categoryFilter?.id == category.id;
              //         return FilterChip(
              //           selected: isSelected,
              //           label: Text(category.name),
              //           onSelected: (_) {
              //             ref.read(productCategoryFilterProvider.notifier).state = isSelected ? null : category;
              //           },
              //           backgroundColor: theme.colorScheme.surface,
              //           selectedColor: theme.colorScheme.primaryContainer,
              //           checkmarkColor: theme.colorScheme.primary,
              //         );
              //       }).toList(),
              //     ],
              //   ),

              const Spacer(),

              // Reset button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
                    ref.read(productCategoryFilterProvider.notifier).state = null;
                  },
                  child: const Text('Đặt lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

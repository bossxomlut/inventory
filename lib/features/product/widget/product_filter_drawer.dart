import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../../provider/index.dart';
import '../../category/provider/category_provider.dart';
import '../provider/product_filter_provider.dart';

class ProductFilterDrawer extends ConsumerWidget {
  const ProductFilterDrawer({Key? key}) : super(key: key);

  // Helper method to build time filter section for both created and updated filters
  Widget _buildTimeFilterSection({
    required BuildContext context,
    required ThemeData theme,
    required WidgetRef ref,
    required String filterType,
  }) {
    final isCreatedFilter = filterType == 'created';
    final filterTypeProvider = isCreatedFilter ? createdTimeFilterTypeProvider : updatedTimeFilterTypeProvider;
    final customRangeProvider = isCreatedFilter ? createdTimeCustomRangeProvider : updatedTimeCustomRangeProvider;

    final selectedFilterType = ref.watch(filterTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: TimeFilterType.values.map((type) {
            final isSelected = selectedFilterType == type;

            if (type == TimeFilterType.custom) {
              return FilterChip(
                selected: isSelected,
                label: Text(type.displayName),
                onSelected: (_) async {
                  // Show date range picker for custom range
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: ref.read(customRangeProvider) ??
                        DateTimeRange(
                          start: DateTime.now().subtract(const Duration(days: 7)),
                          end: DateTime.now(),
                        ),
                  );

                  if (picked != null) {
                    ref.read(customRangeProvider.notifier).state = picked;
                    ref.read(filterTypeProvider.notifier).state = TimeFilterType.custom;
                  }
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
            }

            if (type == TimeFilterType.none) {
              return const SizedBox.shrink(); // Don't show "none" option
            }

            return FilterChip(
              selected: isSelected,
              label: Text(type.displayName),
              onSelected: (_) {
                ref.read(filterTypeProvider.notifier).state = isSelected ? TimeFilterType.none : type;
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

        // Show selected custom date range if applicable
        if (selectedFilterType == TimeFilterType.custom)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Consumer(
              builder: (context, ref, _) {
                final customRange = ref.watch(customRangeProvider);
                if (customRange == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Từ ${customRange.start.day}/${customRange.start.month}/${customRange.start.year} đến ${customRange.end.day}/${customRange.end.month}/${customRange.end.year}',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortType = ref.watch(productSortTypeProvider);
    final selectedCategories = ref.watch(multiSelectCategoryProvider);
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

              Expanded(
                  child: ListView(
                children: [
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
                    'Lọc theo thời gian thêm',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Consumer(
                    builder: (context, ref, _) {
                      final selectedType = ref.watch(createdTimeFilterTypeProvider);
                      final activeFilter = ref.watch(activeTimeFilterTypeProvider);
                      final isDisabled = activeFilter == 'updated';

                      return Wrap(
                        spacing: 8,
                        children: [
                          // Today filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.today,
                            label: const Text('Hôm nay'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thay đổi
                                    if (selectedType == TimeFilterType.today) {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.today;
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'created';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // 7 days filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.last7Days,
                            label: const Text('7 ngày'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thay đổi
                                    if (selectedType == TimeFilterType.last7Days) {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.last7Days;
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'created';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // 1 month filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.last1Month,
                            label: const Text('30 ngày'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thay đổi
                                    if (selectedType == TimeFilterType.last1Month) {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.last1Month;
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'created';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // 3 months filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.last3Months,
                            label: const Text('90 ngày'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thay đổi
                                    if (selectedType == TimeFilterType.last3Months) {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.last3Months;
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'created';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // Custom date range filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.custom,
                            label: const Text('Tùy chỉnh'),
                            onSelected: isDisabled
                                ? null
                                : (_) async {
                                    // Nếu đang chọn thì bỏ chọn
                                    if (selectedType == TimeFilterType.custom) {
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                      return;
                                    }

                                    // Show date range picker
                                    final DateTimeRange? picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                      initialDateRange: ref.read(createdTimeCustomRangeProvider) ??
                                          DateTimeRange(
                                            start: DateTime.now().subtract(const Duration(days: 7)),
                                            end: DateTime.now(),
                                          ),
                                    );

                                    if (picked != null) {
                                      ref.read(createdTimeCustomRangeProvider.notifier).state = picked;
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.custom;
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'created';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),
                        ],
                      );
                    },
                  ),

                  // Show selected custom date range if applicable
                  Consumer(builder: (context, ref, _) {
                    final selectedType = ref.watch(createdTimeFilterTypeProvider);
                    final customRange = ref.watch(createdTimeCustomRangeProvider);

                    if (selectedType == TimeFilterType.custom && customRange != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Từ ${customRange.start.day}/${customRange.start.month}/${customRange.start.year} đến ${customRange.end.day}/${customRange.end.month}/${customRange.end.year}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 24),

                  // Category filter section
                  Text(
                    'Lọc theo thời gian thay đổi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Consumer(
                    builder: (context, ref, _) {
                      final selectedType = ref.watch(updatedTimeFilterTypeProvider);
                      final activeFilter = ref.watch(activeTimeFilterTypeProvider);
                      final isDisabled = activeFilter == 'created';

                      return Wrap(
                        spacing: 8,
                        children: [
                          // Today filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.today,
                            label: const Text('Hôm nay'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thêm
                                    if (selectedType == TimeFilterType.today) {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.today;
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'updated';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // 7 days filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.last7Days,
                            label: const Text('7 ngày'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thêm
                                    if (selectedType == TimeFilterType.last7Days) {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.last7Days;
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'updated';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // 1 month filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.last1Month,
                            label: const Text('30 ngày'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thêm
                                    if (selectedType == TimeFilterType.last1Month) {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.last1Month;
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'updated';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // 3 months filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.last3Months,
                            label: const Text('90 ngày'),
                            onSelected: isDisabled
                                ? null
                                : (_) {
                                    // Nếu đang chọn thì bỏ chọn, ngược lại chọn và reset filter thời gian thêm
                                    if (selectedType == TimeFilterType.last3Months) {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                    } else {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.last3Months;
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'updated';
                                    }
                                  },
                            backgroundColor: isDisabled ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.surfaceVariant,
                          ),

                          // Custom date range filter
                          FilterChip(
                            selected: selectedType == TimeFilterType.custom,
                            label: const Text('Tùy chỉnh'),
                            onSelected: isDisabled
                                ? null
                                : (_) async {
                                    // Nếu đang chọn thì bỏ chọn
                                    if (selectedType == TimeFilterType.custom) {
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                                      return;
                                    }

                                    // Show date range picker
                                    final DateTimeRange? picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                      initialDateRange: ref.read(updatedTimeCustomRangeProvider) ??
                                          DateTimeRange(
                                            start: DateTime.now().subtract(const Duration(days: 7)),
                                            end: DateTime.now(),
                                          ),
                                    );

                                    if (picked != null) {
                                      ref.read(updatedTimeCustomRangeProvider.notifier).state = picked;
                                      ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.custom;
                                      ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                                      ref.read(activeTimeFilterTypeProvider.notifier).state = 'updated';
                                    }
                                  },
                            backgroundColor: theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                          ),
                        ],
                      );
                    },
                  ),

                  // Show selected custom date range if applicable
                  Consumer(builder: (context, ref, _) {
                    final selectedType = ref.watch(updatedTimeFilterTypeProvider);
                    final customRange = ref.watch(updatedTimeCustomRangeProvider);

                    if (selectedType == TimeFilterType.custom && customRange != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Từ ${customRange.start.day}/${customRange.start.month}/${customRange.start.year} đến ${customRange.end.day}/${customRange.end.month}/${customRange.end.year}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }),

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
                            selected: selectedCategories.data.isEmpty,
                            label: const Text('Tất cả'),
                            onSelected: (_) {
                              ref.read(multiSelectCategoryProvider.notifier).clear();
                            },
                            backgroundColor: theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                          ),
                          ...data.map((category) {
                            final isSelected = selectedCategories.isSelected(category);
                            return FilterChip(
                              selected: isSelected,
                              label: Text(category.name),
                              onSelected: (_) {
                                ref.read(multiSelectCategoryProvider.notifier).toggle(category);
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
                ],
              )),

              // Reset button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
                    ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                    ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                    ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                    ref.read(multiSelectCategoryProvider.notifier).clear();
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

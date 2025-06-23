import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../../provider/index.dart';
import '../../../shared_widgets/button/bottom_button_bar.dart';
import '../../category/provider/category_provider.dart';
import '../../unit/provider/unit_filter_provider.dart';
import '../../unit/provider/unit_provider.dart';
import '../provider/product_filter_provider.dart';

class ProductFilterDrawer extends ConsumerWidget {
  const ProductFilterDrawer({Key? key}) : super(key: key);

  // Helper method to build section headers
  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    final appTheme = context.appTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 16.0, right: 16.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: appTheme.colorPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: appTheme.textMedium15Default.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build time filter chips
  Widget _buildTimeFilterChip({
    required BuildContext context,
    required WidgetRef ref,
    required TimeFilterType type,
    required TimeFilterType selectedType,
    required bool isCreatedFilter,
  }) {
    final isSelected = selectedType == type;
    final filterTypeProvider = isCreatedFilter ? createdTimeFilterTypeProvider : updatedTimeFilterTypeProvider;
    final customRangeProvider = isCreatedFilter ? createdTimeCustomRangeProvider : updatedTimeCustomRangeProvider;
    final otherFilterProvider = isCreatedFilter ? updatedTimeFilterTypeProvider : createdTimeFilterTypeProvider;

    if (type == TimeFilterType.custom) {
      return FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(
          type.icon,
          size: 16,
        ),
        label: const Text('Tùy chỉnh'),
        onSelected: (_) async {
          if (isSelected) {
            // Nếu đang chọn thì bỏ chọn
            ref.read(filterTypeProvider.notifier).state = TimeFilterType.none;
            ref.read(activeTimeFilterTypeProvider.notifier).state = null;
            return;
          }

          // Show date range picker
          final DateTimeRange? picked = await _showCustomDateRangePicker(
            context: context,
            initialDateRange: ref.read(customRangeProvider) ??
                DateTimeRange(
                  start: DateTime.now().subtract(const Duration(days: 7)),
                  end: DateTime.now(),
                ),
          );

          if (picked != null) {
            ref.read(customRangeProvider.notifier).state = picked;
            ref.read(filterTypeProvider.notifier).state = TimeFilterType.custom;
            ref.read(otherFilterProvider.notifier).state = TimeFilterType.none;
            ref.read(activeTimeFilterTypeProvider.notifier).state = isCreatedFilter ? 'created' : 'updated';
          }
        },
        elevation: 0,
        side: BorderSide(
          width: 1,
        ),
      );
    }

    if (type == TimeFilterType.none) {
      return const SizedBox.shrink();
    }

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        type.icon,
        size: 16,
      ),
      label: Text(type.displayName),
      onSelected: (_) {
        if (isSelected) {
          ref.read(filterTypeProvider.notifier).state = TimeFilterType.none;
          ref.read(activeTimeFilterTypeProvider.notifier).state = null;
        } else {
          ref.read(filterTypeProvider.notifier).state = type;
          ref.read(otherFilterProvider.notifier).state = TimeFilterType.none;
          ref.read(activeTimeFilterTypeProvider.notifier).state = isCreatedFilter ? 'created' : 'updated';
        }
      },
      elevation: 0,
      side: BorderSide(
        width: 1,
      ),
    );
  }

  // Helper method to build custom date range display
  Widget _buildCustomDateRangeDisplay({
    required BuildContext context,
    required WidgetRef ref,
    required bool isCreatedFilter,
  }) {
    final theme = Theme.of(context); // For theme properties during transition
    final customRangeProvider = isCreatedFilter ? createdTimeCustomRangeProvider : updatedTimeCustomRangeProvider;

    final customRange = ref.watch(customRangeProvider);
    if (customRange == null) return const SizedBox.shrink();

    // Format the date in a more user-friendly way
    final startDay = customRange.start.day.toString().padLeft(2, '0');
    final startMonth = customRange.start.month.toString().padLeft(2, '0');
    final startYear = customRange.start.year;

    final endDay = customRange.end.day.toString().padLeft(2, '0');
    final endMonth = customRange.end.month.toString().padLeft(2, '0');
    final endYear = customRange.end.year;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: () async {
          // Allow editing the custom range by tapping on it
          final DateTimeRange? picked = await _showCustomDateRangePicker(
            context: context,
            initialDateRange: customRange,
          );

          if (picked != null) {
            ref.read(customRangeProvider.notifier).state = picked;
          }
        },
        borderRadius: BorderRadius.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
            borderRadius: BorderRadius.zero,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khoảng thời gian đã chọn:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$startDay/$startMonth/$startYear',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '$endDay/$endMonth/$endYear',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a styled Chip widget with consistent appearance
  Widget _createStyledChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? iconData,
    bool showCheckmark = false,
    Color? backgroundColor,
    Color? selectedColor,
  }) {
    final appTheme = context.appTheme;
    final theme = Theme.of(context); // For theme properties during transition
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        avatar: iconData != null
            ? Icon(
                iconData,
                size: 16,
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
              )
            : isSelected && !showCheckmark
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: appTheme.colorPrimary,
                  )
                : null,
        backgroundColor: isSelected
            ? selectedColor ?? theme.colorScheme.primaryContainer
            : backgroundColor ?? theme.colorScheme.surface,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
        ),
        side: BorderSide(
          color: isSelected ? appTheme.colorPrimary : theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  // Helper method to show date range picker with consistent styling
  Future<DateTimeRange?> _showCustomDateRangePicker({
    required BuildContext context,
    required DateTimeRange? initialDateRange,
  }) async {
    final appTheme = context.appTheme;
    return showDateRangePicker(
      context: context,
      locale: const Locale('vi', 'VN'),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        final appTheme = context.appTheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appTheme.colorPrimary,
              onPrimary: appTheme.colorTextInverse,
              onSurface: appTheme.colorTextDefault,
              secondaryContainer: appTheme.colorSecondary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortType = ref.watch(productSortTypeProvider);
    final selectedCategories = ref.watch(multiSelectCategoryProvider);
    final selectedUnits = ref.watch(multiSelectUnitProvider);
    final categories = ref.watch(allCategoriesProvider);
    final units = ref.watch(allUnitsProvider);
    final appTheme = context.appTheme;

    final hasActiveFilters = sortType != ProductSortType.none ||
        selectedCategories.data.isNotEmpty ||
        selectedUnits.data.isNotEmpty ||
        ref.watch(createdTimeFilterTypeProvider) != TimeFilterType.none ||
        ref.watch(updatedTimeFilterTypeProvider) != TimeFilterType.none;

    return Drawer(
      shape: const RoundedRectangleBorder(),
      backgroundColor: appTheme.colorBackground,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với nền màu sắc
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: appTheme.colorPrimary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bộ lọc sản phẩm',
                  style: appTheme.textMedium16Default.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Main filter content
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),

                // Sort section
                _buildSectionHeader(
                  context: context,
                  title: 'Sắp xếp theo',
                  icon: Icons.sort,
                ),

                Container(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    children: ProductSortType.values.map((type) {
                      final isSelected = sortType == type;
                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        avatar: Icon(
                          type.icon,
                          size: 16,
                        ),
                        label: Text(type.displayName),
                        onSelected: (_) {
                          ref.read(productSortTypeProvider.notifier).state = isSelected ? ProductSortType.none : type;
                        },
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        side: BorderSide(
                          width: 1,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Time Filters with segmented control
                _buildSectionHeader(
                  context: context,
                  title: 'Thời gian',
                  icon: Icons.calendar_today_outlined,
                ),

                // Tab selection control for time filters
                Container(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tab selection
                      Consumer(
                        builder: (context, ref, _) {
                          final activeFilter = ref.watch(activeTimeFilterTypeProvider);
                          return CupertinoSlidingSegmentedControl<String?>(
                            groupValue: activeFilter,
                            padding: EdgeInsets.zero,
                            children: {
                              'created': Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  'Thời gian thêm',
                                  style: TextStyle(
                                    fontWeight: activeFilter == 'created' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              'updated': Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  'Thời gian thay đổi',
                                  style: TextStyle(
                                    fontWeight: activeFilter == 'updated' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            },
                            onValueChanged: (value) {
                              if (value == null) return;
                              ref.read(activeTimeFilterTypeProvider.notifier).state = value;

                              // Reset the other filter type
                              if (value == 'created') {
                                ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                              } else {
                                ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                              }
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Time filter options based on active tab
                      Consumer(
                        builder: (context, ref, _) {
                          final activeFilter = ref.watch(activeTimeFilterTypeProvider);
                          final isCreatedActive = activeFilter == 'created';
                          final currentProvider =
                              isCreatedActive ? createdTimeFilterTypeProvider : updatedTimeFilterTypeProvider;
                          final selectedType = ref.watch(currentProvider);

                          if (activeFilter == null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Chọn loại thời gian để lọc',
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (final type in TimeFilterType.values)
                                    if (type != TimeFilterType.none)
                                      _buildTimeFilterChip(
                                        context: context,
                                        ref: ref,
                                        type: type,
                                        selectedType: selectedType,
                                        isCreatedFilter: isCreatedActive,
                                      ),
                                ],
                              ),

                              // Show date range if custom is selected
                              if (selectedType == TimeFilterType.custom)
                                _buildCustomDateRangeDisplay(
                                  context: context,
                                  ref: ref,
                                  isCreatedFilter: isCreatedActive,
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Category filter section
                _buildSectionHeader(
                  context: context,
                  title: 'Danh mục',
                  icon: Icons.category_outlined,
                ),

                Container(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: categories.when(
                    data: (List<Category> data) {
                      if (data.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Không có danh mục nào'),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick selection row with "All" option
                          InkWell(
                            onTap: () {
                              ref.read(multiSelectCategoryProvider.notifier).clear();
                            },
                            child: Chip(
                              label: Text('Tất cả danh mục'),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              avatar: selectedCategories.data.isEmpty
                                  ? Icon(
                                      Icons.check,
                                      size: 18,
                                    )
                                  : null,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Category filter chips
                          Wrap(
                            spacing: 8,
                            children: data.map((category) {
                              final isSelected = selectedCategories.isSelected(category);
                              return InkWell(
                                onTap: () {
                                  if (!isSelected) {
                                    ref.read(multiSelectCategoryProvider.notifier).toggle(category);
                                  }
                                },
                                child: Chip(
                                  label: Text(category.name),
                                  avatar: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                        )
                                      : null,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  deleteIcon: isSelected ? const Icon(Icons.close, size: 16) : null,
                                  onDeleted: isSelected
                                      ? () {
                                          ref.read(multiSelectCategoryProvider.notifier).toggle(category);
                                        }
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Lỗi tải danh mục: $error',
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Unit filter section
                _buildSectionHeader(
                  context: context,
                  title: 'Đơn vị',
                  icon: Icons.straighten_outlined,
                ),

                Container(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: units.when(
                    data: (List<Unit> data) {
                      if (data.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Không có đơn vị nào'),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick selection row with "All" option
                          InkWell(
                            onTap: () {
                              ref.read(multiSelectUnitProvider.notifier).clear();
                            },
                            child: Chip(
                              label: Text('Tất cả đơn vị'),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              avatar: selectedUnits.data.isEmpty
                                  ? Icon(
                                      Icons.check,
                                      size: 18,
                                    )
                                  : null,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Unit filter chips
                          Wrap(
                            spacing: 8,
                            children: data.map((unit) {
                              final isSelected = selectedUnits.isSelected(unit);
                              return InkWell(
                                onTap: () {
                                  if (!isSelected) {
                                    ref.read(multiSelectUnitProvider.notifier).toggle(unit);
                                  }
                                },
                                child: Chip(
                                  backgroundColor: Colors.red,
                                  surfaceTintColor: Colors.green,
                                  label: Text(unit.name),
                                  avatar: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                        )
                                      : null,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  deleteIcon: isSelected ? const Icon(Icons.close, size: 16) : null,
                                  onDeleted: isSelected
                                      ? () {
                                          ref.read(multiSelectUnitProvider.notifier).toggle(unit);
                                        }
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Lỗi tải đơn vị: $error',
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
          // Bottom action buttons
          BottomButtonBar(
            cancelButtonText: 'Đặt lại',
            saveButtonText: hasActiveFilters ? 'Áp dụng' : 'Đóng',
            onCancel: () {
              ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
              ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
              ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
              ref.read(activeTimeFilterTypeProvider.notifier).state = null;
              ref.read(multiSelectCategoryProvider.notifier).clear();
              ref.read(multiSelectUnitProvider.notifier).clear();
            },
            onSave: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

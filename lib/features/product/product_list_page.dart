import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/entities/product/inventory.dart';
import '../../provider/index.dart';
import '../../provider/load_list.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/app_filter_chip.dart';
import '../../shared_widgets/index.dart';
import '../category/provider/category_provider.dart';
import '../unit/provider/unit_filter_provider.dart';
import 'provider/product_filter_provider.dart';
import 'provider/product_provider.dart';
import 'widget/add_product_widget.dart';
import 'widget/index.dart';

@RoutePage()
class ProductListPage extends HookConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const ProductAppBar(),
      endDrawer: const ProductFilterDrawer(),
      body: const Column(
        children: [
          ProductFilterDisplayWidget(),
          Expanded(child: ProductListView()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(HugeIcons.strokeRoundedAdd01),
        onPressed: () {
          const AddProductScreen().show(context);
        },
      ),
    );
  }
}

///create product appbar widget
class ProductAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const ProductAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchFocusNode = useFocusNode();

    final searchController = useTextEditingController();

    final debouncedSearchText = useDebouncedText(searchController);

    // Trigger search when debounced text changes
    useEffect(() {
      Future(() => ref.read(textSearchProvider.notifier).state = debouncedSearchText);
      return null; // No cleanup needed for search call
    }, [debouncedSearchText]);

    final sortType = ref.watch(productSortTypeProvider);
    final selectedCategories = ref.watch(multiSelectCategoryProvider).data;
    final isSearchVisible = ref.watch(isSearchVisibleProvider);
    final createdTimeFilter = ref.watch(createdTimeFilterTypeProvider);
    final updatedTimeFilter = ref.watch(updatedTimeFilterTypeProvider);

    // Check if any filters are active
    final bool hasActiveFilters = sortType != ProductSortType.none ||
        selectedCategories.isNotEmpty ||
        createdTimeFilter != TimeFilterType.none ||
        updatedTimeFilter != TimeFilterType.none;

    return isSearchVisible
        ? AppBar(
            // Custom search AppBar
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: InkWell(
              child: const Icon(Icons.close, color: Colors.white),
              onTap: () {
                ref.read(isSearchVisibleProvider.notifier).state = false;
                ref.read(textSearchProvider.notifier).state = '';
                searchController.clear();
              },
            ),
            titleSpacing: 0,
            centerTitle: false,
            title: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffix: AnimatedBuilder(
                      animation: searchController,
                      builder: (context, _) {
                        final isNotEmpty = searchController.text.isNotEmpty;
                        if (!isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return InkWell(
                          onTap: () {
                            searchController.clear();
                            ref.read(textSearchProvider.notifier).state = '';
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        );
                      })),
              autofocus: true,
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
            ),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: hasActiveFilters,
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
                onPressed: () {
                  context.hideKeyboard();
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: 'Lọc sản phẩm',
              ),
            ],
          )
        : CustomAppBar(
            title: 'Sản phẩm',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  ref.read(isSearchVisibleProvider.notifier).state = true;
                  // Đảm bảo focus vào text field và mở bàn phím
                  Future.delayed(const Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(searchFocusNode);
                  });
                },
                tooltip: 'Tìm kiếm',
              ),
              Builder(builder: (context) {
                return IconButton(
                  icon: Badge(
                    isLabelVisible: hasActiveFilters,
                    child: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  tooltip: 'Lọc sản phẩm',
                );
              }),
            ],
          );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class ProductFilterDisplayWidget extends ConsumerWidget {
  const ProductFilterDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortType = ref.watch(productSortTypeProvider);
    final selectedCategories = ref.watch(multiSelectCategoryProvider).data;
    final selectedUnits = ref.watch(multiSelectUnitProvider).data;

    // Watch time filters
    final createdTimeFilter = ref.watch(createdTimeFilterTypeProvider);
    final createdTimeCustomRange = ref.watch(createdTimeCustomRangeProvider);
    final updatedTimeFilter = ref.watch(updatedTimeFilterTypeProvider);
    final updatedTimeCustomRange = ref.watch(updatedTimeCustomRangeProvider);

    // Check if any filters are active
    final bool hasActiveFilters = sortType != ProductSortType.none ||
        selectedCategories.isNotEmpty ||
        selectedUnits.isNotEmpty ||
        createdTimeFilter != TimeFilterType.none ||
        updatedTimeFilter != TimeFilterType.none;

    if (!hasActiveFilters) {
      return const SizedBox.shrink();
    }

    // Format a date range for display
    String formatDateRange(DateTime? start, DateTime? end) {
      if (start == null || end == null) return '';
      return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
    }

    // Get created time filter display text
    String getCreatedTimeFilterText() {
      if (createdTimeFilter == TimeFilterType.custom && createdTimeCustomRange != null) {
        return 'Thêm: ${formatDateRange(createdTimeCustomRange.start, createdTimeCustomRange.end)}';
      } else if (createdTimeFilter != TimeFilterType.none) {
        return 'Thêm: ${createdTimeFilter.displayName}';
      }
      return '';
    }

    // Get updated time filter display text
    String getUpdatedTimeFilterText() {
      if (updatedTimeFilter == TimeFilterType.custom && updatedTimeCustomRange != null) {
        return 'Thay đổi: ${formatDateRange(updatedTimeCustomRange.start, updatedTimeCustomRange.end)}';
      } else if (updatedTimeFilter != TimeFilterType.none) {
        return 'Thay đổi: ${updatedTimeFilter.displayName}';
      }
      return '';
    }

    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorBackgroundSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (sortType != ProductSortType.none)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: Text(
                            'Sắp xếp: ${sortType.displayName}',
                            style: theme.textRegular13Subtle,
                          ),
                          avatar: Icon(
                            sortType.icon,
                            size: 16,
                            color: theme.colorPrimary,
                          ),
                          backgroundColor: theme.colorBackground,
                          borderColor: colorScheme.outline.withOpacity(0.3),
                          onDeleted: () {
                            ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
                          },
                        ),
                      ),
                    if (createdTimeFilter != TimeFilterType.none)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: Text(
                            getCreatedTimeFilterText(),
                            style: theme.textRegular13Subtle,
                          ),
                          avatar: Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: theme.colorPrimary,
                          ),
                          backgroundColor: theme.colorBackground,
                          borderColor: colorScheme.outline.withOpacity(0.3),
                          onDeleted: () {
                            ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                            if (ref.read(activeTimeFilterTypeProvider) == 'created') {
                              ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                            }
                          },
                        ),
                      ),
                    if (updatedTimeFilter != TimeFilterType.none)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: Text(
                            getUpdatedTimeFilterText(),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          avatar: Icon(
                            Icons.update_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          backgroundColor: colorScheme.surfaceVariant,
                          borderColor: colorScheme.outline.withOpacity(0.3),
                          onDeleted: () {
                            ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                            if (ref.read(activeTimeFilterTypeProvider) == 'updated') {
                              ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                            }
                          },
                        ),
                      ),
                    if (selectedCategories.isNotEmpty) ...[
                      for (final category in selectedCategories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppFilterChip(
                            avatar: Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: colorScheme.secondary,
                            ),
                            label: Text(
                              category.name,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: colorScheme.secondaryContainer.withOpacity(0.3),
                            borderColor: colorScheme.secondaryContainer,
                            onDeleted: () {
                              ref.read(multiSelectCategoryProvider.notifier).toggle(category);
                            },
                          ),
                        ),
                    ],
                    if (selectedUnits.isNotEmpty) ...[
                      for (final unit in selectedUnits)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppFilterChip(
                            avatar: Icon(
                              Icons.straighten_outlined,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            label: Text(
                              unit.name,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
                            borderColor: colorScheme.primaryContainer,
                            onDeleted: () {
                              ref.read(multiSelectUnitProvider.notifier).toggle(unit);
                            },
                          ),
                        ),
                    ]
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () {
                  ref.read(productSortTypeProvider.notifier).state = ProductSortType.none;
                  ref.read(multiSelectCategoryProvider.notifier).clear();
                  ref.read(multiSelectUnitProvider.notifier).clear();
                  ref.read(createdTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                  ref.read(updatedTimeFilterTypeProvider.notifier).state = TimeFilterType.none;
                  ref.read(activeTimeFilterTypeProvider.notifier).state = null;
                },
                icon: Icon(
                  Icons.filter_list_off,
                  size: 18,
                  color: colorScheme.primary,
                ),
                label: Text(
                  'Xóa tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListView extends HookConsumerWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use loadProductProvider directly
    final products = ref.watch(loadProductProvider);

    if (products.hasError) {
      return Center(child: Text('Error: ${products.error}'));
    } else if (products.isEmpty) {
      return const EmptyItemWidget();
    } else {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text('Đã tải ${products.data.length}/${products.totalCount} sản phẩm'),
          ),
          Expanded(
            child: LoadMoreList<Product>(
              items: products.data,
              itemBuilder: (context, index) {
                final product = products.data[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    // Navigate to product detail screen
                    appRouter.goToProductDetail(product);
                  },
                );
              },
              separatorBuilder: (context, index) => const AppDivider(),
              onLoadMore: () async {
                print('Loading more products...');
                return Future(
                  () {
                    return ref.read(loadProductProvider.notifier).loadMore();
                  },
                );
              },
              isCanLoadMore: !products.isEndOfList,
            ),
          ),
        ],
      );
    }
  }
}

class EmptyItemWidget extends StatelessWidget {
  const EmptyItemWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

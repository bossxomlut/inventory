import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/text_search.dart';
import '../../category/provider/category_provider.dart';
import '../../unit/provider/unit_filter_provider.dart';

enum ProductSortType { none, nameAsc, nameDesc, quantityAsc, quantityDesc }

enum TimeFilterType { none, today, last7Days, last1Month, last3Months, custom }

extension ProductSortTypeExtension on ProductSortType {
  String get displayName {
    switch (this) {
      case ProductSortType.nameAsc:
        return 'Tên A-Z';
      case ProductSortType.nameDesc:
        return 'Tên Z-A';
      case ProductSortType.quantityAsc:
        return 'Số lượng tăng dần';
      case ProductSortType.quantityDesc:
        return 'Số lượng giảm dần';
      case ProductSortType.none:
        return 'Mặc định';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductSortType.nameAsc:
        return Icons.sort_by_alpha;
      case ProductSortType.nameDesc:
        return Icons.sort_by_alpha;
      case ProductSortType.quantityAsc:
        return Icons.arrow_upward;
      case ProductSortType.quantityDesc:
        return Icons.arrow_downward;
      case ProductSortType.none:
        return Icons.sort;
    }
  }
}

extension TimeFilterTypeExtension on TimeFilterType {
  String get displayName {
    switch (this) {
      case TimeFilterType.today:
        return 'Hôm nay';
      case TimeFilterType.last7Days:
        return '7 ngày';
      case TimeFilterType.last1Month:
        return '30 ngày';
      case TimeFilterType.last3Months:
        return '90 ngày';
      case TimeFilterType.custom:
        return 'Tùy chỉnh';
      case TimeFilterType.none:
        return 'Không lọc';
    }
  }

  IconData get icon {
    switch (this) {
      case TimeFilterType.today:
        return Icons.today;
      case TimeFilterType.last7Days:
        return Icons.date_range;
      case TimeFilterType.last1Month:
        return Icons.calendar_month;
      case TimeFilterType.last3Months:
        return Icons.calendar_today;
      case TimeFilterType.custom:
        return Icons.calendar_view_month;
      case TimeFilterType.none:
        return Icons.filter_alt_off;
    }
  }

  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case TimeFilterType.today:
        return DateTime(now.year, now.month, now.day);
      case TimeFilterType.last7Days:
        return now.subtract(const Duration(days: 7));
      case TimeFilterType.last1Month:
        return DateTime(now.year, now.month - 1, now.day);
      case TimeFilterType.last3Months:
        return DateTime(now.year, now.month - 3, now.day);
      case TimeFilterType.custom:
      case TimeFilterType.none:
        return null;
    }
  }

  DateTime? get endDate {
    final now = DateTime.now();
    if (this == TimeFilterType.none || this == TimeFilterType.custom) {
      return null;
    }
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
}

final productSortTypeProvider = StateProvider.autoDispose<ProductSortType>((ref) => ProductSortType.none);

// Created time filter provider
final createdTimeFilterTypeProvider = StateProvider.autoDispose<TimeFilterType>((ref) => TimeFilterType.none);

// Custom date range for created time
final createdTimeCustomRangeProvider = StateProvider.autoDispose<DateTimeRange?>((ref) => null);

// Updated time filter provider
final updatedTimeFilterTypeProvider = StateProvider.autoDispose<TimeFilterType>((ref) => TimeFilterType.none);

// Custom date range for updated time
final updatedTimeCustomRangeProvider = StateProvider.autoDispose<DateTimeRange?>((ref) => null);

// Provider để theo dõi trạng thái chọn giữa created và updated
final activeTimeFilterTypeProvider = StateProvider.autoDispose<String?>((ref) => null);

final productFilterProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final searchQuery = ref.watch(textSearchProvider).trim();
  final selectedCategories = ref.watch(multiSelectCategoryProvider).data;
  final selectedUnits = ref.watch(multiSelectUnitProvider).data;
  final sortType = ref.watch(productSortTypeProvider);

  // Create filter map to pass to repository
  final Map<String, dynamic> filter = {};

  // Add search query to filter if available
  if (searchQuery.isNotEmpty) {
    filter['search'] = searchQuery;
  }

  // Add created time filter if available
  final createdTimeFilter = ref.watch(createdTimeFilterTypeProvider);
  if (createdTimeFilter != TimeFilterType.none) {
    if (createdTimeFilter == TimeFilterType.custom) {
      final customRange = ref.watch(createdTimeCustomRangeProvider);
      if (customRange != null) {
        filter['createdStartDate'] = customRange.start;
        filter['createdEndDate'] = customRange.end;
      }
    } else {
      filter['createdStartDate'] = createdTimeFilter.startDate;
      filter['createdEndDate'] = createdTimeFilter.endDate;
    }
  }

  // Add updated time filter if available
  final updatedTimeFilter = ref.watch(updatedTimeFilterTypeProvider);
  if (updatedTimeFilter != TimeFilterType.none) {
    if (updatedTimeFilter == TimeFilterType.custom) {
      final customRange = ref.watch(updatedTimeCustomRangeProvider);
      if (customRange != null) {
        filter['updatedStartDate'] = customRange.start;
        filter['updatedEndDate'] = customRange.end;
      }
    } else {
      filter['updatedStartDate'] = updatedTimeFilter.startDate;
      filter['updatedEndDate'] = updatedTimeFilter.endDate;
    }
  }

  // Add categoryId to filter if available
  if (selectedCategories.isNotEmpty) {
    filter['categoryIds'] = selectedCategories.map((category) => category.id).toList();
  }

  // Add unitId to filter if available
  if (selectedUnits.isNotEmpty) {
    filter['unitIds'] = selectedUnits.map((unit) => unit.id).toList();
  }

  // Add sortType to filter if available
  if (sortType != ProductSortType.none) {
    switch (sortType) {
      case ProductSortType.nameAsc:
        filter['sortType'] = 'nameAsc';
        break;
      case ProductSortType.nameDesc:
        filter['sortType'] = 'nameDesc';
        break;
      case ProductSortType.quantityAsc:
        filter['sortType'] = 'quantityAsc';
        break;
      case ProductSortType.quantityDesc:
        filter['sortType'] = 'quantityDesc';
        break;
      case ProductSortType.none:
        break;
    }
  }

  return filter;
});

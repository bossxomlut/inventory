import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/text_search.dart';
import '../../category/provider/category_provider.dart';

enum ProductSortType { nameAsc, nameDesc, quantityAsc, quantityDesc, none }

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

final productSortTypeProvider = StateProvider.autoDispose<ProductSortType>((ref) => ProductSortType.none);

final productFilterProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final searchQuery = ref.watch(textSearchProvider).trim();
  final selectedCategories = ref.watch(multiSelectCategoryProvider).data;
  final sortType = ref.watch(productSortTypeProvider);

  // Create filter map to pass to repository
  final Map<String, dynamic> filter = {};

  // Add search query to filter if available
  if (searchQuery.isNotEmpty) {
    filter['search'] = searchQuery;
  }

  // Add categoryId to filter if available
  if (selectedCategories.isNotEmpty) {
    filter['categoryIds'] = selectedCategories.map((category) => category.id).toList();
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

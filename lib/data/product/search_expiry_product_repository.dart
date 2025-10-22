import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';

import '../../domain/entities/index.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../features/product/provider/product_filter_provider.dart';
import '../../provider/load_list.dart';
import '../database/isar_repository.dart';
import 'inventory.dart';
import 'inventory_mapping.dart';

class SearchExpiryProductRepositoryImpl extends SearchExpiryProductRepository {
  final Isar _isar = Isar.getInstance()!;

  IsarCollection<ProductCollection> get _collection =>
      _isar.collection<ProductCollection>();

  QueryBuilder<ProductCollection, ProductCollection, QAfterFilterCondition>
      _buildFilteredQuery({
    required String keyword,
    Iterable<int>? selectedCategoryIds,
    Iterable<int>? selectedUnitIds,
    DateTime? createdStartDate,
    DateTime? createdEndDate,
    DateTime? updatedStartDate,
    DateTime? updatedEndDate,
    String? expiryTracking,
  }) {
    return _collection
        .filter()
        .group(
          (q) => q
              .nameContains(keyword, caseSensitive: false)
              .or()
              .barcodeContains(keyword, caseSensitive: false)
              .or()
              .descriptionContains(keyword, caseSensitive: false),
        )
        .optional(
          createdStartDate != null && createdEndDate != null,
          (q) => q.createdAtBetween(createdStartDate!, createdEndDate!),
        )
        .optional(
          updatedStartDate != null && updatedEndDate != null,
          (q) => q.updatedAtBetween(updatedStartDate!, updatedEndDate!),
        )
        .optional(
          selectedCategoryIds?.isNotEmpty ?? false,
          (q) => q.category(
            (categoryQuery) => categoryQuery.anyOf<int, ProductCollection>(
              selectedCategoryIds!,
              (categoryQuery, id) => categoryQuery.idEqualTo(id),
            ),
          ),
        )
        .optional(
          selectedUnitIds?.isNotEmpty ?? false,
          (q) => q.unit(
            (unitQuery) => unitQuery.anyOf<int, ProductCollection>(
              selectedUnitIds!,
              (unitQuery, id) => unitQuery.idEqualTo(id),
            ),
          ),
        )
        .optional(
          expiryTracking == 'trackingOnly',
          (q) => q.enableExpiryTrackingEqualTo(true),
        )
        .optional(
          expiryTracking == 'nonTracking',
          (q) => q.enableExpiryTrackingEqualTo(false),
        );
  }

  QueryBuilder<ProductCollection, ProductCollection, QAfterSortBy> _applySort(
    QueryBuilder<ProductCollection, ProductCollection, QAfterFilterCondition>
        query,
    ProductSortType sortType,
  ) {
    switch (sortType) {
      case ProductSortType.nameAsc:
        return query.sortByName();
      case ProductSortType.nameDesc:
        return query.sortByNameDesc();
      case ProductSortType.quantityAsc:
        return query.sortByQuantity().thenByName();
      case ProductSortType.quantityDesc:
        return query.sortByQuantityDesc().thenByName();
      case ProductSortType.none:
        break;
    }
    return query.sortByName();
  }

  @override
  Future<LoadResult<Product>> search(
    String keyword,
    int page,
    int limit, {
    Map<String, dynamic>? filter,
  }) async {
    final Iterable<int>? selectedCategoryIds =
        filter?['categoryIds'] as Iterable<int>?;
    final Iterable<int>? selectedUnitIds = filter?['unitIds'] as Iterable<int>?;
    final String sortTypeName = filter?['sortType'] as String? ?? 'none';
    final DateTime? createdStartDate = filter?['createdStartDate'] as DateTime?;
    final DateTime? createdEndDate = filter?['createdEndDate'] as DateTime?;
    final DateTime? updatedStartDate = filter?['updatedStartDate'] as DateTime?;
    final DateTime? updatedEndDate = filter?['updatedEndDate'] as DateTime?;
    final String? expiryTracking = filter?['expiryTracking'] as String?;

    final ProductSortType sortType = ProductSortType.values.firstWhere(
      (value) => value.name == sortTypeName,
      orElse: () => ProductSortType.none,
    );

    final queryForResults = _buildFilteredQuery(
      keyword: keyword,
      selectedCategoryIds: selectedCategoryIds,
      selectedUnitIds: selectedUnitIds,
      createdStartDate: createdStartDate,
      createdEndDate: createdEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
      expiryTracking: expiryTracking,
    );

    final queryForCount = _buildFilteredQuery(
      keyword: keyword,
      selectedCategoryIds: selectedCategoryIds,
      selectedUnitIds: selectedUnitIds,
      createdStartDate: createdStartDate,
      createdEndDate: createdEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
      expiryTracking: expiryTracking,
    );

    final sortedQuery = _applySort(queryForResults, sortType);

    final collections =
        await sortedQuery.offset((page - 1) * limit).limit(limit).findAll();

    final products = <Product>[];
    for (final collection in collections) {
      await collection.images.load();
      await collection.lots.load();
      await collection.category.load();
      await collection.unit.load();
      products.add(ProductMapping().from(collection));
    }

    return LoadResult<Product>(
      data: products,
      totalCount: await queryForCount.count(),
    );
  }

  @override
  Future<ProductExpirySummary> expirySummary(
    String keyword,
    Map<String, dynamic>? filter, {
    int soonThresholdDays = 7,
  }) async {
    final Iterable<int>? selectedCategoryIds =
        filter?['categoryIds'] as Iterable<int>?;
    final Iterable<int>? selectedUnitIds = filter?['unitIds'] as Iterable<int>?;
    final DateTime? createdStartDate = filter?['createdStartDate'] as DateTime?;
    final DateTime? createdEndDate = filter?['createdEndDate'] as DateTime?;
    final DateTime? updatedStartDate = filter?['updatedStartDate'] as DateTime?;
    final DateTime? updatedEndDate = filter?['updatedEndDate'] as DateTime?;
    final String? expiryTracking = filter?['expiryTracking'] as String?;

    final query = _buildFilteredQuery(
      keyword: keyword,
      selectedCategoryIds: selectedCategoryIds,
      selectedUnitIds: selectedUnitIds,
      createdStartDate: createdStartDate,
      createdEndDate: createdEndDate,
      updatedStartDate: updatedStartDate,
      updatedEndDate: updatedEndDate,
      expiryTracking: expiryTracking,
    );

    final collections = await query.findAll();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime soonThreshold = today.add(Duration(days: soonThresholdDays));

    int trackingProducts = 0;
    int expiredLots = 0;
    int expiringSoonLots = 0;

    for (final collection in collections) {
      if (!collection.enableExpiryTracking) {
        continue;
      }

      trackingProducts++;
      await collection.lots.load();

      if (collection.lots.isEmpty) {
        continue;
      }

      for (final lot in collection.lots) {
        final expiry = DateTime(
          lot.expiryDate.year,
          lot.expiryDate.month,
          lot.expiryDate.day,
        );

        if (expiry.isBefore(today)) {
          expiredLots++;
          continue;
        }

        if (!expiry.isAfter(soonThreshold) && !expiry.isBefore(today)) {
          expiringSoonLots++;
        }
      }
    }

    return ProductExpirySummary(
      totalTrackingProducts: trackingProducts,
      expiredProducts: expiredLots,
      expiringSoonProducts: expiringSoonLots,
      soonThresholdDays: soonThresholdDays,
    );
  }
}

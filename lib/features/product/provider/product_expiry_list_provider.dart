import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/repositories/product/inventory_repository.dart';

part 'product_expiry_list_provider.g.dart';

const int _expirySoonThresholdDays = 7;
const int _expiryPageSize = 20;

enum ProductExpiryTrackingFilter { tracking, nonTracking }

enum ProductExpiryStatusFilter { expiringSoon, expired, all }

final productExpiryTrackingFilterProvider =
    StateProvider.autoDispose<ProductExpiryTrackingFilter>(
        (ref) => ProductExpiryTrackingFilter.tracking);

final productExpiryStatusFilterProvider =
    StateProvider.autoDispose<ProductExpiryStatusFilter>(
        (ref) => ProductExpiryStatusFilter.expiringSoon);

final productExpirySearchKeywordProvider =
    StateProvider.autoDispose<String>((ref) => '');

class ProductExpiryListState {
  const ProductExpiryListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.initialized = false,
  });

  final List<Product> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool initialized;

  ProductExpiryListState copyWith({
    List<Product>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? initialized,
  }) {
    return ProductExpiryListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      initialized: initialized ?? this.initialized,
    );
  }
}

@riverpod
class ProductExpiryListController extends _$ProductExpiryListController {
  SearchExpiryProductRepository get _repository =>
      ref.read(searchExpiryProductRepositoryProvider);

  String get _keyword => ref.read(productExpirySearchKeywordProvider).trim();

  ProductExpiryTrackingFilter get _trackingFilter =>
      ref.read(productExpiryTrackingFilterProvider);

  ProductExpiryStatusFilter get _statusFilter =>
      ref.read(productExpiryStatusFilterProvider);

  @override
  ProductExpiryListState build() {
    ref.listen(productExpiryTrackingFilterProvider, (_, __) => _resetAndLoad());
    ref.listen(productExpiryStatusFilterProvider, (_, __) => _resetAndLoad());
    ref.listen(productExpirySearchKeywordProvider, (_, __) => _resetAndLoad());

    Future.microtask(_resetAndLoad);
    return const ProductExpiryListState();
  }

  Future<void> _resetAndLoad() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      initialized: true,
      hasMore: true,
      currentPage: 0,
      items: const [],
      error: null,
    );

    await _fetchPage(1, append: false);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    await _fetchPage(state.currentPage + 1, append: true);
  }

  Future<void> _fetchPage(int page, {required bool append}) async {
    if (append) {
      state = state.copyWith(isLoadingMore: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final filter = <String, dynamic>{};
    switch (_trackingFilter) {
      case ProductExpiryTrackingFilter.tracking:
        filter['expiryTracking'] = 'trackingOnly';
        break;
      case ProductExpiryTrackingFilter.nonTracking:
        filter['expiryTracking'] = 'nonTracking';
        break;
    }

    try {
      var currentPage = page;
      final buffer = <Product>[];
      var hasMore = true;

      while (true) {
        final result = await _repository.search(
          _keyword,
          currentPage,
          _expiryPageSize,
          filter: filter,
        );

        final raw = result.data;
        if (raw.isEmpty) {
          hasMore = false;
          break;
        }

        final filtered = _applyStatusFilter(raw);
        buffer.addAll(filtered);

        if (raw.length < _expiryPageSize) {
          hasMore = false;
        }

        if (filtered.isNotEmpty || !hasMore) {
          break;
        }

        currentPage += 1;
      }

      final updatedItems = append ? [...state.items, ...buffer] : buffer;

      state = state.copyWith(
        items: updatedItems,
        currentPage: currentPage,
        hasMore: hasMore,
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  List<Product> _applyStatusFilter(List<Product> products) {
    if (_trackingFilter == ProductExpiryTrackingFilter.nonTracking) {
      return products;
    }

    switch (_statusFilter) {
      case ProductExpiryStatusFilter.expired:
        return products.where(_hasExpired).toList();
      case ProductExpiryStatusFilter.expiringSoon:
        return products
            .where(
                (product) => !_hasExpired(product) && _hasExpiringSoon(product))
            .toList();
      case ProductExpiryStatusFilter.all:
        return products;
    }
  }

  bool _hasExpired(Product product) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return product.lots.any((lot) {
      final expiry = DateTime(
        lot.expiryDate.year,
        lot.expiryDate.month,
        lot.expiryDate.day,
      );
      return expiry.isBefore(todayDate);
    });
  }

  bool _hasExpiringSoon(Product product) {
    if (product.lots.isEmpty) {
      return false;
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final soonThreshold =
        todayDate.add(const Duration(days: _expirySoonThresholdDays));
    for (final lot in product.lots) {
      final expiry = DateTime(
        lot.expiryDate.year,
        lot.expiryDate.month,
        lot.expiryDate.day,
      );
      if (!expiry.isBefore(todayDate) && !expiry.isAfter(soonThreshold)) {
        return true;
      }
    }
    return false;
  }
}

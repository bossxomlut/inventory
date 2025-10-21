import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/index.dart';
import '../../provider/index.dart';
import '../../resources/index.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/hook/text_controller_hook.dart';
import '../../shared_widgets/list_view/load_more_list.dart';
import 'provider/product_expiry_list_provider.dart';
import 'provider/product_expiry_summary_provider.dart';
import 'widget/product_card.dart';
import 'widget/product_expiry_status_badge.dart';
import 'widget/product_expiry_summary_banner.dart';

@RoutePage()
class ProductExpiryPage extends HookConsumerWidget {
  const ProductExpiryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final searchController = useTextEditingController();
    final String searchKeyword = ref.watch(productExpirySearchKeywordProvider);
    final debouncedSearchText = useDebouncedText(searchController);

    useEffect(() {
      if (searchController.text != searchKeyword) {
        searchController.value = searchController.value.copyWith(
          text: searchKeyword,
          selection: TextSelection.collapsed(offset: searchKeyword.length),
        );
      }
      return null;
    }, [searchKeyword]);

    useEffect(() {
      final normalized = debouncedSearchText.trim();
      if (ref.read(productExpirySearchKeywordProvider) != normalized) {
        Future(() => ref
            .read(productExpirySearchKeywordProvider.notifier)
            .state = normalized);
      }
      return null;
    }, [debouncedSearchText]);

    final trackingFilter = ref.watch(productExpiryTrackingFilterProvider);
    final statusFilter = ref.watch(productExpiryStatusFilterProvider);
    final listState = ref.watch(productExpiryListControllerProvider);
    final listNotifier = ref.read(productExpiryListControllerProvider.notifier);

    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);

    Widget buildTrackingFilterChip({
      required ProductExpiryTrackingFilter value,
      required IconData icon,
    }) {
      final isSelected = trackingFilter == value;
      return ChoiceChip(
        selected: isSelected,
        label: Text(
          value == ProductExpiryTrackingFilter.tracking
              ? t(LKey.productExpiryFilterTracking)
              : t(LKey.productExpiryFilterNonTracking),
        ),
        avatar: Icon(icon, size: 18),
        onSelected: (_) {
          ref.read(productExpiryTrackingFilterProvider.notifier).state = value;
          if (value == ProductExpiryTrackingFilter.nonTracking) {
            ref.read(productExpiryStatusFilterProvider.notifier).state =
                ProductExpiryStatusFilter.all;
          }
        },
      );
    }

    Widget buildStatusChip({
      required ProductExpiryStatusFilter value,
      required String labelKey,
    }) {
      final isSelected = statusFilter == value;
      return ChoiceChip(
        selected: isSelected,
        label: Text(t(labelKey)),
        onSelected: (_) =>
            ref.read(productExpiryStatusFilterProvider.notifier).state = value,
      );
    }

    final headerHeight = _pinnedHeaderHeight(trackingFilter);

    return Scaffold(
      appBar: CustomAppBar(
        title: t(LKey.productExpiryPageTitle),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) {
          return [
            SliverToBoxAdapter(
              child: const ProductExpirySummaryBanner(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ExpirySearchHeaderDelegate(
                height: headerHeight,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: t(LKey.productExpirySearchHint),
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorBorderField),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            buildTrackingFilterChip(
                              value: ProductExpiryTrackingFilter.tracking,
                              icon: Icons.verified_outlined,
                            ),
                            buildTrackingFilterChip(
                              value: ProductExpiryTrackingFilter.nonTracking,
                              icon: Icons.not_interested_outlined,
                            ),
                          ],
                        ),
                      ),
                      if (trackingFilter == ProductExpiryTrackingFilter.tracking)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              buildStatusChip(
                                value: ProductExpiryStatusFilter.expired,
                                labelKey: LKey.productExpiryTabExpired,
                              ),
                              buildStatusChip(
                                value: ProductExpiryStatusFilter.expiringSoon,
                                labelKey: LKey.productExpiryTabExpiringSoon,
                              ),
                              buildStatusChip(
                                value: ProductExpiryStatusFilter.all,
                                labelKey: LKey.productExpiryTabAll,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: _ExpiryListContent(
          state: listState,
          trackingFilter: trackingFilter,
          loadMore: listNotifier.loadMore,
        ),
      ),
    );
  }
}

class _ExpiryListContent extends StatelessWidget {
  const _ExpiryListContent({
    required this.state,
    required this.trackingFilter,
    required this.loadMore,
  });

  final ProductExpiryListState state;
  final ProductExpiryTrackingFilter trackingFilter;
  final Future<void> Function() loadMore;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Text(
            '${LKey.commonErrorWithMessage.tr(context: context, namedArgs: {
                  'error': state.error!
                })}',
            textAlign: TextAlign.center,
            style: theme.textRegular15Subtle,
          ),
        ),
      );
    }

    if (!state.isLoading && state.items.isEmpty) {
      final emptyText = trackingFilter == ProductExpiryTrackingFilter.tracking
          ? LKey.productExpiryEmptyTracking.tr(context: context)
          : LKey.productExpiryEmptyNonTracking.tr(context: context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: theme.textRegular15Subtle,
          ),
        ),
      );
    }

    return LoadMoreList<Product>(
      items: state.items,
      itemBuilder: (context, index) {
        final product = state.items[index];
        return _ExpiryProductTile(product: product);
      },
      separatorBuilder: (_, __) => const AppDivider(),
      onLoadMore: loadMore,
      isCanLoadMore: state.hasMore,
      padding: EdgeInsets.zero,
    );
  }
}

double _pinnedHeaderHeight(ProductExpiryTrackingFilter filter) {
  const baseHeight = 128.0; // search + tracking chips + spacing
  const statusHeight = 56.0;
  return filter == ProductExpiryTrackingFilter.tracking
      ? baseHeight + statusHeight
      : baseHeight;
}

class _ExpirySearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ExpirySearchHeaderDelegate({
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (overlapsContent)
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _ExpirySearchHeaderDelegate oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}

const int _expirySoonBadgeThresholdDays = 7;

class _ExpiryProductTile extends HookConsumerWidget {
  const _ExpiryProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lots = product.lots;
    final trackingFilter = ref.watch(productExpiryTrackingFilterProvider);

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final sortedLots = [...lots]
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final badgeWidgets = <Widget>[];
    String? infoText;

    if (trackingFilter == ProductExpiryTrackingFilter.nonTracking) {
      infoText = LKey.productExpiryItemNoTracking.tr(context: context);
    } else if (sortedLots.isEmpty) {
      infoText = LKey.productExpiryItemNoLot.tr(context: context);
    } else {
      final earliestExpiry = DateTime(
        sortedLots.first.expiryDate.year,
        sortedLots.first.expiryDate.month,
        sortedLots.first.expiryDate.day,
      );
      final earliestText = DateFormat('dd/MM/yyyy').format(earliestExpiry);

      for (final lot in sortedLots) {
        final expiry = DateTime(
          lot.expiryDate.year,
          lot.expiryDate.month,
          lot.expiryDate.day,
        );
        final diff = expiry.difference(todayDate).inDays;
        final isExpired = diff < 0;
        final isExpiringSoon =
            !isExpired && diff <= _expirySoonBadgeThresholdDays;

        if (!isExpired && !isExpiringSoon) {
          continue;
        }

        final status = buildProductExpiryStatus(
          context: context,
          daysDifference: diff,
        );
        final dateLabel = DateFormat('dd/MM').format(expiry);
        badgeWidgets.add(
          ProductExpiryStatusBadge(
            status: ProductExpiryStatus(
              text: '${status.text} • $dateLabel',
              color: status.color,
            ),
          ),
        );
      }

      infoText = LKey.productExpiryItemEarliest.tr(
        context: context,
        namedArgs: {'date': earliestText},
      );
    }

    final subtitleChildren = <Widget>[];
    if (badgeWidgets.isNotEmpty) {
      subtitleChildren.add(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final chip in badgeWidgets) ...[
                chip,
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      );
    }
    if (infoText != null) {
      if (subtitleChildren.isNotEmpty) {
        subtitleChildren.add(const SizedBox(height: 4));
      }
      subtitleChildren.add(
        Text(
          infoText,
          style: context.appTheme.textRegular12Subtle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: CustomProductCard(
        product: product,
        onTap: () => appRouter.goToProductDetail(product),
        subtitleWidget: subtitleChildren.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subtitleChildren,
              ),
        trailingWidget: QuantityWidget(quantity: product.quantity),
      ),
    );
  }
}

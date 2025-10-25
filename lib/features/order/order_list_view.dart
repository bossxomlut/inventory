import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/order/order.dart';
import '../../core/helpers/double_utils.dart';
import '../../core/index.dart';
import '../../domain/index.dart';
import '../../provider/index.dart';
import '../../provider/permissions.dart';
import '../../resources/index.dart';
import '../../resources/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import '../setting/provider/currency_settings_provider.dart';
import 'order_list_view.dart';
import 'provider/order_action_confirm_provider.dart';
import 'provider/order_action_handler.dart';
import 'provider/order_list_provider.dart';
import 'provider/order_status_count_provider.dart';
import 'widget/order_card.dart';

class OrderListView extends HookConsumerWidget {
  const OrderListView({
    super.key,
    required this.status,
    required this.canCreateOrder,
    required this.canDeleteOrder,
    required this.canCompleteOrder,
    required this.canCancelOrder,
  });

  final OrderStatus status;
  final bool canCreateOrder;
  final bool canDeleteOrder;
  final bool canCompleteOrder;
  final bool canCancelOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final debouncedSearch = useDebouncedText(searchController);

    useEffect(() {
      Future(() {
        ref.read(orderSearchKeywordProvider(status).notifier).state = debouncedSearch;
      });
      return null;
    }, [debouncedSearch, status]);

    final orders = ref.watch(orderListProvider(status));
    final actionHandler = ref.read(orderActionHandlerProvider);
    ref.watch(currencySettingsControllerProvider);
    String t(String key) => key.tr(context: context);

    VoidCallback? buildRemoveCallback(Order order) {
      if (!canDeleteOrder) {
        return null;
      }
      switch (status) {
        case OrderStatus.draft:
          return () => actionHandler.deleteOrder(context, OrderStatus.draft, order);
        case OrderStatus.done:
          return () => actionHandler.deleteOrder(context, OrderStatus.done, order);
        case OrderStatus.cancelled:
          return () => actionHandler.deleteOrder(context, OrderStatus.cancelled, order);
        case OrderStatus.confirmed:
          return null;
      }
    }

    VoidCallback? buildCompleteCallback(Order order) {
      if (status != OrderStatus.confirmed || !canCompleteOrder) {
        return null;
      }
      return () => actionHandler.completeOrder(context, order);
    }

    VoidCallback? buildCancelCallback(Order order) {
      if (status != OrderStatus.confirmed || !canCancelOrder) {
        return null;
      }
      return () => actionHandler.cancelOrder(context, order);
    }

    Widget buildBody() {
      if (orders.isLoading && orders.data.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (orders.error != null && orders.data.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              LKey.commonErrorWithMessage.tr(
                context: context,
                namedArgs: {'error': orders.error!},
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      if (orders.data.isEmpty) {
        return OrderEmptyState(
          status: status,
          canCreateOrder: canCreateOrder,
        );
      }

      return LoadMoreList<Order>(
        items: orders.data,
        itemBuilder: (context, index) {
          final order = orders.data[index];

          return Consumer(
            builder: (context, ref, _) {
              final selectionState = ref.watch(confirmedOrderSelectionProvider);
              final isSelected = selectionState?.data.contains(order) ?? false;

              return OrderCard(
                order: order,
                onRemove: buildRemoveCallback(order),
                onComplete: buildCompleteCallback(order),
                onCancel:buildCancelCallback(order),
                isSelected: isSelected,
                onSelectionToggle: status == OrderStatus.confirmed && canCompleteOrder ? () {
                  ref.read(confirmedOrderSelectionProvider.notifier).toggle(order);
                } : null,
              );
            }
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        onLoadMore: () async {
          return Future(
            () {
              return ref.read(orderListProvider(status).notifier).loadMore();
            },
          );
        },
        isCanLoadMore: !orders.isEndOfList,
      );
    }

    return Column(
      children: [
        AppSearchField(
          keyDetectorKey: '${status.name}-order-search-field',
          controller: searchController,
          hintText: t(LKey.orderListSearchHint),
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        ),
        const AppDivider(),
        Expanded(child: buildBody()),
        if (status == OrderStatus.confirmed && canCompleteOrder)
          Consumer(
            builder: (context, ref, _) {
              final selectionState = ref.watch(confirmedOrderSelectionProvider);
              final selectedCount = selectionState?.data.length ?? 0;
              final totalCountAsync =
                  ref.watch(orderStatusCountProvider(OrderStatus.confirmed));
              final totalCount = totalCountAsync.maybeWhen(
                data: (value) => value,
                orElse: () => 0,
              );
              return _OrderSelectionActionBar(
                selectedCount: selectedCount,
                totalCount: totalCount,
                onCompleteAll: () {
                  _completeAllConfirmedOrders(context, ref);
                },
                onCompleteSelected: () {
                  _completeSelectedConfirmedOrders(context, ref);
                },
              );
            },
          ),
      ],
    );
  }

  String _tr(BuildContext context, String key,
      {Map<String, String>? namedArgs}) =>
      key.tr(context: context, namedArgs: namedArgs);

  Future<void> _completeAllConfirmedOrders(
      BuildContext context, WidgetRef ref) async {
    final notifier =
        ref.read(orderListProvider(OrderStatus.confirmed).notifier);
    final orders = await notifier.fetchAllOrders();
    if (orders.isEmpty) {
      showError(
        context: context,
        message: _tr(context, LKey.orderListBulkEmptySelection),
      );
      return;
    }

    final confirmed = await _showBulkConfirmationDialog(
      context,
      message: _tr(
        context,
        LKey.orderListBulkConfirmAll,
        namedArgs: {'count': '${orders.length}'},
      ),
    );

    if (!confirmed) {
      return;
    }

    await notifier.confirmOrdersBulk(orders);

    ref.read(confirmedOrderSelectionProvider.notifier).disableAndClear();
  }

  Future<void> _completeSelectedConfirmedOrders(
      BuildContext context, WidgetRef ref) async {
    final selectionState = ref.read(confirmedOrderSelectionProvider);
    final orders = selectionState.data.toList();
    if (orders.isEmpty) {
      showError(
        context: context,
        message: _tr(context, LKey.orderListBulkEmptySelection),
      );
      return;
    }

    final confirmed = await _showBulkConfirmationDialog(
      context,
      message: _tr(
        context,
        LKey.orderListBulkConfirmSelected,
        namedArgs: {'count': '${orders.length}'},
      ),
    );

    if (!confirmed) {
      return;
    }

    await ref
        .read(orderListProvider(OrderStatus.confirmed).notifier)
        .confirmOrdersBulk(orders);

    ref.read(confirmedOrderSelectionProvider.notifier).disableAndClear();
  }

  Future<bool> _showBulkConfirmationDialog(
      BuildContext context, {
        required String message,
      }) async {
    context.hideKeyboard();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_tr(context, LKey.orderActionConfirmTitle)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_tr(context, LKey.buttonCancel)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_tr(context, LKey.buttonConfirm)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _OrderSearchEmpty extends StatelessWidget {
  const _OrderSearchEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: theme.textRegular15Subtle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _OrderSelectionActionBar extends StatelessWidget {
  const _OrderSelectionActionBar({
    required this.selectedCount,
    required this.totalCount,
    required this.onCompleteAll,
    required this.onCompleteSelected,
  });

  final int selectedCount;
  final int totalCount;
  final VoidCallback onCompleteAll;
  final VoidCallback onCompleteSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    String t(String key, {Map<String, String>? namedArgs}) => key.tr(context: context, namedArgs: namedArgs);

    final summary = t(
      LKey.orderListBulkSummary,
      namedArgs: {
        'selected': '$selectedCount',
        'total': '$totalCount',
      },
    );

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                summary,
                style: theme.textRegular15Default,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      title: t(LKey.orderListBulkCompleteAll),
                      onPressed: totalCount > 0 ? onCompleteAll : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.primary(
                      title: t(LKey.orderListBulkCompleteSelected),
                      onPressed: selectedCount > 0 ? onCompleteSelected : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderEmptyState extends StatelessWidget {
  const OrderEmptyState({
    super.key,
    required this.status,
    required this.canCreateOrder,
  });

  final OrderStatus status;
  final bool canCreateOrder;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    String t(String key) => key.tr(context: context);

    String getMessage() {
      switch (status) {
        case OrderStatus.draft:
          return t(LKey.orderListEmptyDraft);
        case OrderStatus.confirmed:
          return t(LKey.orderListEmptyConfirmed);
        case OrderStatus.done:
          return t(LKey.orderListEmptyDone);
        case OrderStatus.cancelled:
          return t(LKey.orderListEmptyCancelled);
      }
    }

    IconData getIcon() {
      switch (status) {
        case OrderStatus.draft:
          return Icons.edit_note_outlined;
        case OrderStatus.confirmed:
          return Icons.check_circle_outline;
        case OrderStatus.done:
          return Icons.task_alt_outlined;
        case OrderStatus.cancelled:
          return Icons.cancel_outlined;
      }
    }

    Color getIconColor() {
      switch (status) {
        case OrderStatus.draft:
          return Colors.orange;
        case OrderStatus.confirmed:
          return Colors.blue;
        case OrderStatus.done:
          return Colors.green;
        case OrderStatus.cancelled:
          return Colors.red;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getIcon(),
            size: 80,
            color: getIconColor().withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            getMessage(),
            style: theme.textRegular16Subtle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (canCreateOrder)
            Text(
              t(LKey.orderListCreateHint),
              style: theme.textRegular14Sublest,
              textAlign: TextAlign.center,
            )
          else
            Text(
              t(LKey.orderListContactAdmin),
              style: theme.textRegular14Sublest,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

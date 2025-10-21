import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../setting/provider/currency_settings_provider.dart';
import 'provider/order_action_confirm_provider.dart';
import 'provider/order_action_handler.dart';
import 'provider/order_list_provider.dart';

@RoutePage()
class OrderStatusListPage extends ConsumerStatefulWidget {
  const OrderStatusListPage({super.key});

  @override
  ConsumerState<OrderStatusListPage> createState() =>
      _OrderStatusListPageState();
}

class _OrderStatusListPageState extends ConsumerState<OrderStatusListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<OrderStatus> _visibleStatuses = const [];
  final List<OrderStatus> statuses = [
    OrderStatus.draft,
    OrderStatus.confirmed,
    OrderStatus.done,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: statuses.length,
      vsync: this,
      initialIndex: 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _syncTabController(List<OrderStatus> visibleStatuses) {
    if (listEquals(_visibleStatuses, visibleStatuses)) {
      return;
    }

    OrderStatus? previousStatus;
    if (_visibleStatuses.isNotEmpty &&
        _tabController.index < _visibleStatuses.length) {
      previousStatus = _visibleStatuses[_tabController.index];
    }

    final fallbackStatus = visibleStatuses.contains(OrderStatus.confirmed)
        ? OrderStatus.confirmed
        : visibleStatuses.first;
    final targetStatus =
        previousStatus != null && visibleStatuses.contains(previousStatus)
            ? previousStatus
            : fallbackStatus;
    final targetIndex = visibleStatuses.indexOf(targetStatus);

    _tabController.dispose();
    final clampedIndex = targetIndex < 0
        ? 0
        : targetIndex >= visibleStatuses.length
            ? visibleStatuses.length - 1
            : targetIndex;
    _tabController = TabController(
      length: visibleStatuses.length,
      vsync: this,
      initialIndex: clampedIndex,
    );
    _visibleStatuses = List<OrderStatus>.from(visibleStatuses);
  }

  VoidCallback? _buildRemoveCallback(BuildContext context, WidgetRef ref,
      OrderStatus status, Order order, bool canDelete) {
    if (!canDelete) {
      return null;
    }

    switch (status) {
      case OrderStatus.draft:
        return () async {
          await ref
              .read(orderActionHandlerProvider)
              .deleteOrder(context, OrderStatus.draft, order);
        };
      case OrderStatus.done:
        return () async {
          await ref
              .read(orderActionHandlerProvider)
              .deleteOrder(context, OrderStatus.done, order);
        };
      case OrderStatus.cancelled:
        return () async {
          await ref
              .read(orderActionHandlerProvider)
              .deleteOrder(context, OrderStatus.cancelled, order);
        };
      case OrderStatus.confirmed:
        return null;
    }
  }

  VoidCallback? _buildCompleteCallback(BuildContext context, WidgetRef ref,
      OrderStatus status, Order order, bool canComplete) {
    if (status != OrderStatus.confirmed || !canComplete) {
      return null;
    }

    return () async {
      await ref.read(orderActionHandlerProvider).completeOrder(context, order);
    };
  }

  VoidCallback? _buildCancelCallback(BuildContext context, WidgetRef ref,
      OrderStatus status, Order order, bool canCancel) {
    if (status != OrderStatus.confirmed || !canCancel) {
      return null;
    }

    return () async {
      await ref.read(orderActionHandlerProvider).cancelOrder(context, order);
    };
  }

  String _statusLabel(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return LKey.orderStatusDraft.tr(context: context);
      case OrderStatus.confirmed:
        return LKey.orderStatusConfirmed.tr(context: context);
      case OrderStatus.done:
        return LKey.orderStatusDone.tr(context: context);
      case OrderStatus.cancelled:
        return LKey.orderStatusCancelled.tr(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    ref.watch(currencySettingsControllerProvider);
    String t(String key) => key.tr(context: context);

    return permissionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber,
                    size: 40, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  t(LKey.permissionsLoadFailed),
                  style: theme.textMedium16Default,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentUserPermissionsProvider),
                  child: Text(t(LKey.buttonRetry)),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (permissions) {
        final canViewDraft = permissions.contains(PermissionKey.orderViewDraft);
        final canViewConfirmed =
            permissions.contains(PermissionKey.orderViewConfirmed);
        final canViewDone = permissions.contains(PermissionKey.orderViewDone);
        final canViewCancelled =
            permissions.contains(PermissionKey.orderViewCancelled);
        final canCreate = permissions.contains(PermissionKey.orderCreate);
        final canDelete = permissions.contains(PermissionKey.orderDelete);
        final canComplete = permissions.contains(PermissionKey.orderComplete);
        final canCancel = permissions.contains(PermissionKey.orderCancel);

        final visibleStatuses = [
          if (canViewDraft) OrderStatus.draft,
          if (canViewConfirmed) OrderStatus.confirmed,
          if (canViewDone) OrderStatus.done,
          if (canViewCancelled) OrderStatus.cancelled,
        ];

        if (visibleStatuses.isEmpty) {
          return Scaffold(
            appBar: CustomAppBar(title: t(LKey.orderListTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t(LKey.orderListPermissionDenied),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        _syncTabController(visibleStatuses);

        return Scaffold(
          appBar: CustomAppBar(
            title: t(LKey.orderListTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                color: Colors.white,
                tooltip: t(LKey.orderListSettingsTooltip),
                onPressed: () => _openConfirmSettingsDialog(context),
              ),
            ],
            bottom: TabBar(
              labelStyle:
                  theme.textMedium15Default.copyWith(color: Colors.white),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              controller: _tabController,
              tabs: visibleStatuses.map((status) {
                return Consumer(
                  builder: (context, ref, child) {
                    final orders = ref.watch(orderListProvider(status));
                    final count = orders.data.length;
                    return Tab(
                      text: '${_statusLabel(context, status)} ($count)',
                    );
                  },
                );
              }).toList(),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: visibleStatuses.map((status) {
              return OrderListView(
                status: status,
                itemBuilder: (BuildContext context, Order order, int index) {
                  return OrderCard(
                    order: order,
                    onRemove: _buildRemoveCallback(
                        context, ref, status, order, canDelete),
                    onComplete: _buildCompleteCallback(
                        context, ref, status, order, canComplete),
                    onCancel: _buildCancelCallback(
                        context, ref, status, order, canCancel),
                  );
                },
                canCreateOrder: canCreate,
              );
            }).toList(),
          ),
          floatingActionButton: canCreate
              ? FloatingActionButton(
                  onPressed: () {
                    appRouter.goToCreateOrder().whenComplete(
                      () {
                        if (!mounted) {
                          return;
                        }
                        ref.invalidate(orderListProvider(OrderStatus.draft));
                        ref.invalidate(
                            orderListProvider(OrderStatus.confirmed));
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Future<void> _openConfirmSettingsDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final settingsAsync = ref.watch(orderActionConfirmControllerProvider);
          String t(String key) => key.tr(context: context);
          return settingsAsync.when(
            loading: () => const AlertDialog(
              content: SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stack) => AlertDialog(
              title: Text(t(LKey.orderListSettingsTitle)),
              content: Text(
                LKey.orderListSettingsLoadError.tr(
                  namedArgs: {'error': '$error'},
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(t(LKey.buttonClose)),
                ),
              ],
            ),
            data: (settings) {
              final notifier =
                  ref.read(orderActionConfirmControllerProvider.notifier);
              return AlertDialog(
                title: Text(t(LKey.orderListSettingsTitle)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionToggle(
                      context,
                      title: t(LKey.orderListToggleConfirmTitle),
                      description: t(LKey.orderListToggleConfirmDescription),
                      value: settings.confirm,
                      onChanged: (value) => notifier.setActionEnabled(
                          OrderActionType.confirm, value),
                    ),
                    _buildActionToggle(
                      context,
                      title: t(LKey.orderListToggleCancelTitle),
                      description: t(LKey.orderListToggleCancelDescription),
                      value: settings.cancel,
                      onChanged: (value) => notifier.setActionEnabled(
                          OrderActionType.cancel, value),
                    ),
                    _buildActionToggle(
                      context,
                      title: t(LKey.orderListToggleDeleteTitle),
                      description: t(LKey.orderListToggleDeleteDescription),
                      value: settings.delete,
                      onChanged: (value) => notifier.setActionEnabled(
                          OrderActionType.delete, value),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await notifier.reset();
                    },
                    child: Text(t(LKey.orderListSettingsReset)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(t(LKey.buttonClose)),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionToggle(
    BuildContext context, {
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: value,
      title: Text(title),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onChanged: onChanged,
    );
  }
}

class OrderListView extends ConsumerWidget {
  const OrderListView({
    super.key,
    required this.status,
    required this.itemBuilder,
    required this.canCreateOrder,
  });

  final OrderStatus status;
  final Widget Function(BuildContext context, Order oder, int index)
      itemBuilder;
  final bool canCreateOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider(status));
    ref.watch(currencySettingsControllerProvider);

    if (orders.data.isEmpty && !orders.isLoading) {
      return OrderEmptyState(status: status, canCreateOrder: canCreateOrder);
    }

    return LoadMoreList<Order>(
      items: orders.data,
      itemBuilder: (context, index) {
        final order = orders.data[index];
        return itemBuilder(context, order, index);
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
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onRemove,
    this.onComplete,
    this.onCancel,
  });

  final Order order;
  final VoidCallback? onRemove;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    String t(String key) => key.tr(context: context);
    final notSet = t(LKey.orderCommonNotSet);
    final customerName =
        order.customer.isNotNullOrEmpty ? order.customer! : notSet;
    final contactName = order.customerContact.isNotNullOrEmpty
        ? order.customerContact!
        : notSet;

    return InkWell(
      onTap: () {
        appRouter.goToOrderDetail(order);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Mã đơn hàng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LKey.orderListOrderCode.tr(
                          namedArgs: {'id': '${order.id}'},
                        ),
                        style: theme.textMedium15Default,
                      ),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(order.orderDate)}',
                        style: theme.textRegular14Sublest,
                      ),
                    ],
                  ),
                  Gap(8),
                  Row(
                    children: [
                      //Tên khách hàng
                      Text(
                        LKey.orderListCustomer.tr(
                          namedArgs: {'name': customerName},
                        ),
                        style: theme.textRegular15Default,
                      ),
                      VerticalDivider(), //contact
                      Text(
                        LKey.orderListContact.tr(
                          namedArgs: {'contact': contactName},
                        ),
                        style: theme.textRegular14Sublest,
                      ),
                    ],
                  ),

                  Gap(8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        Row(
                          children: [
                            //Sản phẩm
                            //Số sản phẩm
                            Text(
                              t(LKey.orderListProductsLabel),
                              style: theme.textRegular13Subtle,
                            ),
                            Gap(4),
                            Text(
                              '${order.productCount}',
                              style: theme.textRegular15Default,
                            ),
                            //Tổng tiền
                          ],
                        ),
                        Gap(20),
                        Row(
                          children: [
                            //Sản phẩm
                            //Số sản phẩm
                            Text(
                              t(LKey.orderListQuantityLabel),
                              style: theme.textRegular13Subtle,
                            ),
                            Gap(4),
                            Text(
                              '${order.totalAmount}',
                              style: theme.textRegular15Default,
                            ),
                            //Tổng tiền
                          ],
                        ),
                        Gap(20),
                        Row(
                          children: [
                            //Sản phẩm
                            //Số sản phẩm
                            Text(
                              t(LKey.orderListTotalLabel),
                              style: theme.textRegular13Subtle,
                            ),
                            Gap(4),
                            Text(
                              '${order.totalPrice.priceFormat()}',
                              style: theme.textRegular15Default,
                            ), //Tổng tiền
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (order.note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        LKey.orderListNoteLabel
                            .tr(namedArgs: {'note': order.note!}),
                        style: theme.textRegular15Subtle,
                      ),
                    ),
                ],
              ),
              const Gap(10),
              const AppDivider(),
              const Gap(4),
              buildTrailing(
                context,
                order.status,
                theme,
              ),
            ],
          )),
    );
  }

  Widget buildTrailing(
      BuildContext context, OrderStatus status, AppThemeData theme) {
    String t(String key) => key.tr(context: context);
    switch (status) {
      case OrderStatus.confirmed:
        final bool canComplete = onComplete != null;
        final bool canCancelOrder = onCancel != null;
        if (!canComplete && !canCancelOrder) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //Button: Hoàn thành
            if (canComplete)
              TextButton(
                onPressed: onComplete,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
                child: Text(
                  t(LKey.orderListActionComplete),
                  style:
                      theme.textRegular15Default.copyWith(color: Colors.green),
                ),
              ),
            if (canComplete && canCancelOrder) const Gap(12),
            //Button: Huỷ
            if (canCancelOrder)
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red.withOpacity(0.1),
                ),
                child: Text(
                  t(LKey.orderListActionCancel),
                  style: theme.textRegular15Default.copyWith(color: Colors.red),
                ),
              ),
          ],
        );
      case OrderStatus.draft:
      case OrderStatus.done:
      case OrderStatus.cancelled:
        if (onRemove == null) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
              child: Text(
                t(LKey.buttonDelete),
                style: theme.textRegular15Default.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
    }
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

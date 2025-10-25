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

@RoutePage()
class OrderStatusListPage extends ConsumerStatefulWidget {
  const OrderStatusListPage({super.key});

  @override
  ConsumerState<OrderStatusListPage> createState() => _OrderStatusListPageState();
}

class _OrderStatusListPageState extends ConsumerState<OrderStatusListPage> with TickerProviderStateMixin {
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
    if (_visibleStatuses.isNotEmpty && _tabController.index < _visibleStatuses.length) {
      previousStatus = _visibleStatuses[_tabController.index];
    }

    final fallbackStatus =
        visibleStatuses.contains(OrderStatus.confirmed) ? OrderStatus.confirmed : visibleStatuses.first;
    final targetStatus =
        previousStatus != null && visibleStatuses.contains(previousStatus) ? previousStatus : fallbackStatus;
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
                const Icon(Icons.warning_amber, size: 40, color: Colors.redAccent),
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
        final canViewConfirmed = permissions.contains(PermissionKey.orderViewConfirmed);
        final canViewDone = permissions.contains(PermissionKey.orderViewDone);
        final canViewCancelled = permissions.contains(PermissionKey.orderViewCancelled);
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
              labelStyle: theme.textMedium15Default.copyWith(color: Colors.white),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              controller: _tabController,
              tabs: visibleStatuses.map((status) {
                return Consumer(
                  builder: (context, ref, child) {
                    final countAsync = ref.watch(orderStatusCountProvider(status));
                    final count = countAsync.maybeWhen(
                      data: (value) => value,
                      orElse: () => 0,
                    );
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
            children: visibleStatuses.map<Widget>((status) {
              return OrderListView(
                status: status,
                canCreateOrder: canCreate,
                canDeleteOrder: canDelete,
                canCompleteOrder: canComplete,
                canCancelOrder: canCancel,
              );
            }).toList(),
          ),
          floatingActionButton: canCreate
              ? AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    final floatingButton = FloatingActionButton(
                      onPressed: () {
                        appRouter.goToCreateOrder().whenComplete(
                          () {
                            if (!mounted) {
                              return;
                            }
                            ref.invalidate(orderListProvider(OrderStatus.draft));
                            ref.invalidate(orderListProvider(OrderStatus.confirmed));
                          },
                        );
                      },
                      child: const Icon(Icons.add),
                    );
                    if (visibleStatuses[_tabController.index] == OrderStatus.confirmed && canComplete) {
                      return AnimatedPadding(
                        padding: EdgeInsets.only(bottom: 120),
                        child: floatingButton,
                        duration: Duration(milliseconds: 200),
                      );
                    }

                    return  AnimatedPadding(
                      padding: EdgeInsets.zero,
                      child: floatingButton,
                      duration: Duration(milliseconds: 200),
                    );
                  })
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
              final notifier = ref.read(orderActionConfirmControllerProvider.notifier);
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
                      onChanged: (value) => notifier.setActionEnabled(OrderActionType.confirm, value),
                    ),
                    _buildActionToggle(
                      context,
                      title: t(LKey.orderListToggleCancelTitle),
                      description: t(LKey.orderListToggleCancelDescription),
                      value: settings.cancel,
                      onChanged: (value) => notifier.setActionEnabled(OrderActionType.cancel, value),
                    ),
                    _buildActionToggle(
                      context,
                      title: t(LKey.orderListToggleDeleteTitle),
                      description: t(LKey.orderListToggleDeleteDescription),
                      value: settings.delete,
                      onChanged: (value) => notifier.setActionEnabled(OrderActionType.delete, value),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../authentication/provider/auth_provider.dart';
import '../../../domain/entities/order/order.dart';
import '../../../routes/app_router.dart';
import '../../home/menu_manager.dart';
import 'order_action_confirm_provider.dart';
import 'order_list_provider.dart';

part 'order_action_handler.g.dart';

@riverpod
OrderActionHandler orderActionHandler(OrderActionHandlerRef ref) {
  return OrderActionHandler(ref);
}

class OrderActionHandler {
  OrderActionHandler(this._ref);

  final Ref _ref;

  Future<bool> confirmAction(
    BuildContext context,
    OrderActionType type,
    Order order,
  ) async {
    final settings = await _ref.read(orderActionConfirmControllerProvider.future);
    if (!settings.isEnabled(type)) {
      return true;
    }

    final title = switch (type) {
      OrderActionType.confirm => 'Xác nhận hành động',
      OrderActionType.cancel => 'Huỷ đơn hàng',
      OrderActionType.delete => 'Xoá đơn hàng',
    };

    final message = switch (type) {
      OrderActionType.confirm =>
          'Bạn có chắc chắn muốn hoàn thành đơn hàng #${order.id}?',
      OrderActionType.cancel =>
          'Bạn có chắc chắn muốn huỷ đơn hàng #${order.id}?',
      OrderActionType.delete =>
          'Bạn có chắc chắn muốn xoá đơn hàng #${order.id}?',
    };

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> deleteOrder(
    BuildContext context,
    OrderStatus status,
    Order order,
  ) async {
    final confirmed = await confirmAction(context, OrderActionType.delete, order);
    if (!confirmed) {
      return;
    }

    _ref.read(orderListProvider(status).notifier).removeOrder(order);
  }

  Future<void> completeOrder(BuildContext context, Order order) async {
    final confirmed = await confirmAction(context, OrderActionType.confirm, order);
    if (!confirmed) {
      return;
    }

    await _ref.read(orderListProvider(OrderStatus.confirmed).notifier).confirmOrder(order);
    _ref.invalidate(orderListProvider(OrderStatus.done));
  }

  Future<void> cancelOrder(BuildContext context, Order order) async {
    final confirmed = await confirmAction(context, OrderActionType.cancel, order);
    if (!confirmed) {
      return;
    }

    await _ref.read(orderListProvider(OrderStatus.confirmed).notifier).cancelOrder(order);
    _ref.invalidate(orderListProvider(OrderStatus.cancelled));
  }
}

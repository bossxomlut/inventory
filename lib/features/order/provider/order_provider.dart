import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';

part 'order_provider.freezed.dart';
part 'order_provider.g.dart';

@riverpod
class OrderCreation extends _$OrderCreation {
  @override
  OrderState build() {
    return OrderState(orders: []);
  }

  void addOrderItem(OrderItem orderItem) {
    state = state.copyWith(orders: [
      orderItem,
      ...state.orders,
    ]);
  }

  void updateOrderItem(int index, OrderItem orderItem) {
    if (index < 0 || index >= state.orders.length) {
      throw RangeError('Index out of range');
    }
    final updatedOrders = List<OrderItem>.from(state.orders);
    updatedOrders[index] = orderItem;
    state = state.copyWith(orders: updatedOrders);
  }

  void updateOrderItem2(OrderItem orderItem) {
    final index = state.orders.indexWhere((item) => item.product.id == orderItem.product.id);
    if (index != -1) {
      updateOrderItem(index, orderItem);
    } else {
      addOrderItem(orderItem);
    }
  }

  void removeOrderItem(int index) {
    if (index < 0 || index >= state.orders.length) {
      throw RangeError('Index out of range');
    }
  }

  void remove(OrderItem orderItem) {
    final updatedOrders = List<OrderItem>.from(state.orders);
    updatedOrders.removeWhere((item) => item.product.id == orderItem.product.id);
    state = state.copyWith(orders: updatedOrders);
  }
}

@freezed
class OrderState with _$OrderState {
  const factory OrderState({
    Order? order,
    required List<OrderItem> orders,
  }) = _OrderState;
}

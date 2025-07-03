import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';

part 'order_provider.freezed.dart';
part 'order_provider.g.dart';

@riverpod
class OrderCreation extends _$OrderCreation {
  @override
  OrderState build() {
    return const OrderState(orderItems: {});
  }

  void addOrderItem(Product product, OrderItem orderItem) {
    state = OrderState(
      order: state.order,
      orderItems: {
        ...state.orderItems,
        product: orderItem,
      },
    );
  }

  void updateOrderItem(Product product, OrderItem orderItem) {
    state = state.copyWith(
      orderItems: {
        ...state.orderItems,
        product: orderItem,
      },
    );
  }

  void remove(Product product) {
    final updatedOrderItems = Map<Product, OrderItem>.from(state.orderItems);
    updatedOrderItems.remove(product);
    state = state.copyWith(orderItems: updatedOrderItems);
  }
}

@freezed
class OrderState with _$OrderState {
  const factory OrderState({
    Order? order,
    required Map<Product, OrderItem> orderItems,
  }) = _OrderState;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/order/order_repository.dart';
import '../../../provider/index.dart';

part 'order_provider.freezed.dart';
part 'order_provider.g.dart';

@riverpod
class OrderCreation extends _$OrderCreation with CommonProvider<OrderState> {
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

  void createOrder() async {
    showLoading();

    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.createOrder(
        Order(
          id: undefinedId,
          status: OrderStatus.confirmed,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
          createdBy: '',
          totalAmount: state.totalQuantity,
          totalPrice: state.totalPrice,
        ),
        state.orderItems.values.toList());

    hideLoading();

    state = const OrderState(orderItems: {});

    showSuccess('Tạo đơn hàng thành công');

    // appRouter.popForced();
  }

  void saveDraft() {}
}

@freezed
class OrderState with _$OrderState {
  const factory OrderState({
    Order? order,
    required Map<Product, OrderItem> orderItems,
  }) = _OrderState;
}

extension OrderStateX on OrderState {
  bool get isEmpty => orderItems.isEmpty;

  bool get isNotEmpty => orderItems.isNotEmpty;

  double get totalPrice {
    return orderItems.values.fold(0.0, (total, item) => total + item.price * item.quantity);
  }

  int get totalQuantity {
    return orderItems.values.fold(0, (total, item) => total + item.quantity);
  }
}

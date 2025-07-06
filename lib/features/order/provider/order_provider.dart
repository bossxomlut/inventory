import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/order/order_repository.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
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
          productCount: state.orderItems.length,
          totalAmount: state.totalQuantity,
          totalPrice: state.totalPrice,
          customer: state.order?.customer,
          customerContact: state.order?.customerContact,
          note: state.order?.note,
        ),
        state.orderItems.values.toList());

    hideLoading();

    state = const OrderState(orderItems: {});

    showSuccess('Tạo đơn hàng thành công');
  }

  void saveDraft() {
    showLoading();

    final orderRepository = ref.read(orderRepositoryProvider);
    orderRepository
        .createOrder(
      Order(
        id: undefinedId,
        status: OrderStatus.draft,
        orderDate: DateTime.now(),
        createdAt: DateTime.now(),
        createdBy: '',
        productCount: state.orderItems.length,
        totalAmount: state.totalQuantity,
        totalPrice: state.totalPrice,
        customer: state.order?.customer,
        customerContact: state.order?.customerContact,
        note: state.order?.note,
      ),
      state.orderItems.values.toList(),
    )
        .then((_) {
      hideLoading();
      state = const OrderState(orderItems: {});
      showSuccess('Lưu nháp đơn hàng thành công');
    }).onError((error, st) {
      hideLoading();
      showError('Lỗi khi lưu nháp đơn hàng');
      log('create draft error', error: error, stackTrace: st);
    });
  }

  void setCustomerInfo(String name, String contact) {
    final currentOrder = state.order;
    if (currentOrder != null) {
      state = state.copyWith(
        order: currentOrder.copyWith(
          customer: name,
          customerContact: contact,
        ),
      );
    } else {
      state = state.copyWith(
        order: Order(
          id: undefinedId,
          status: OrderStatus.draft,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
          createdBy: '',
          productCount: state.orderItems.length,
          totalAmount: state.totalQuantity,
          totalPrice: state.totalPrice,
          customer: name,
          customerContact: contact,
          note: state.order?.note,
        ),
      );
    }
  }

  void setNote(String note) {
    final currentOrder = state.order;
    if (currentOrder != null) {
      state = state.copyWith(
        order: currentOrder.copyWith(note: note),
      );
    } else {
      state = state.copyWith(
        order: Order(
          id: undefinedId,
          status: OrderStatus.draft,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
          createdBy: '',
          productCount: state.orderItems.length,
          totalAmount: state.totalQuantity,
          totalPrice: state.totalPrice,
          note: note,
          customer: state.order?.customer,
          customerContact: state.order?.customerContact,
        ),
      );
    }
  }
}

@riverpod
class OrderDetail extends _$OrderDetail with CommonProvider<OrderState> {
  @override
  OrderState build(Order order) {
    Future(() {
      final orderItemRepository = ref.read(orderItemRepositoryProvider);
      orderItemRepository.getItemsByOrderId(order.id).then((items) async {
        final productRepository = ref.read(productRepositoryProvider);
        final orderItems = <Product, OrderItem>{};
        for (final item in items) {
          final product = await productRepository.read(item.productId);
          orderItems[product] = item;
        }
        state = OrderState(order: order, orderItems: orderItems);
      }).onError((error, stackTrace) {
        log('Error fetching order items', error: error, stackTrace: stackTrace);
        state = OrderState(order: order, orderItems: {});
      });
    });
    return OrderState(order: order, orderItems: {});
  }
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

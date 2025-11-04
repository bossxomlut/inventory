import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/order/order_repository.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';
import '../../../resources/index.dart';
import 'order_list_provider.dart';

part 'order_provider.freezed.dart';
part 'order_provider.g.dart';

@riverpod
class OrderCreation extends _$OrderCreation with CommonProvider<OrderState> {
  static const _completeOnCreateStorageKey = 'order.create.completeOnCreate.enabled';

  @override
  OrderState build() {
    Future(() async {
      final storage = ref.read(simpleStorageProvider);
      await storage.init();
      final storedValue = await storage.getBool(_completeOnCreateStorageKey);
      if (storedValue != null && storedValue != state.completeOnCreate) {
        state = state.copyWith(completeOnCreate: storedValue);
      }
    });
    return const OrderState(orderItems: <Product, OrderItem>{});
  }

  void addOrderItem(Product product, OrderItem orderItem) {
    final updatedItems = Map<Product, OrderItem>.from(state.orderItems)..[product] = orderItem;
    state = state.copyWith(orderItems: updatedItems);
  }

  void updateOrderItem(Product product, OrderItem orderItem) {
    final updatedItems = Map<Product, OrderItem>.from(state.orderItems)..[product] = orderItem;
    state = state.copyWith(orderItems: updatedItems);
  }

  void remove(Product product) {
    final updatedOrderItems = Map<Product, OrderItem>.from(state.orderItems);
    updatedOrderItems.remove(product);
    state = state.copyWith(orderItems: updatedOrderItems);
  }

  void setCompleteOnCreate(bool value) {
    if (state.completeOnCreate == value) {
      return;
    }
    state = state.copyWith(completeOnCreate: value);
    final storage = ref.read(simpleStorageProvider);
    storage.init().then((_) => storage.saveBool(_completeOnCreateStorageKey, value));
  }

  Future<Order> createOrder() async {
    showLoading();

    final orderRepository = ref.read(orderRepositoryProvider);
    final permissionsAsync = ref.read(currentUserPermissionsProvider);
    final permissions = permissionsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final canCompleteOrder = permissions?.contains(PermissionKey.orderComplete) ?? false;
    final shouldComplete = canCompleteOrder && state.completeOnCreate;
    final targetStatus = shouldComplete ? OrderStatus.done : OrderStatus.confirmed;
    final now = DateTime.now();
    final DateTime? updatedAt = shouldComplete ? now : null;

    final createdOrder = await orderRepository.createOrder(
      Order(
        id: haveInitOrder ? state.order!.id : undefinedId,
        status: targetStatus,
        orderDate: now,
        createdAt: now,
        updatedAt: updatedAt,
        createdBy: '',
        productCount: state.orderItems.length,
        totalAmount: state.totalQuantity,
        totalPrice: state.totalPrice,
        customer: state.order?.customer,
        customerContact: state.order?.customerContact,
        note: state.order?.note,
      ),
      state.orderItems.values.toList(),
    );

    refreshDraftOrderList();
    ref.invalidate(orderListProvider(OrderStatus.confirmed));
    if (targetStatus == OrderStatus.done) {
      ref.invalidate(orderListProvider(OrderStatus.done));
    }

    hideLoading();

    final keepCompleteOnCreate =
        permissions == null ? state.completeOnCreate : state.completeOnCreate && canCompleteOrder;
    state = OrderState(
      orderItems: const <Product, OrderItem>{},
      completeOnCreate: keepCompleteOnCreate,
    );

    if (targetStatus == OrderStatus.done) {
      showSuccess(
        LKey.orderCompleteSuccess.tr(
          namedArgs: {'orderId': '${createdOrder.id}'},
        ),
      );
    } else {
      showSuccess(LKey.orderCreateSuccess.tr());
    }

    return createdOrder;
  }

  Future saveDraft() async {
    showLoading();

    final orderRepository = ref.read(orderRepositoryProvider);

    await orderRepository
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
      refreshDraftOrderList();

      hideLoading();
      final keepCompleteOnCreate = state.completeOnCreate;
      state = OrderState(
        orderItems: const <Product, OrderItem>{},
        completeOnCreate: keepCompleteOnCreate,
      );
      showSuccess(LKey.orderDraftSuccess.tr());
    }).onError((error, st) {
      hideLoading();
      showError(LKey.orderDraftError.tr());
      log('create draft error', error: error, stackTrace: st);
    });
  }

  void setCustomerInfo(String name, String contact) {
    final currentOrder = state.order;
    if (currentOrder != null) {
      state = state.copyWith(
        order: currentOrder.copyWith(
          customer: name.isNotEmpty ? name : null,
          customerContact: contact.isNotEmpty ? contact : null,
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
          customer: name.isNotEmpty ? name : null,
          customerContact: contact.isNotEmpty ? contact : null,
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

  void initializeOrder(Order order) async {
    if (order.id == undefinedId) {
      state = state.copyWith(
        order: order,
        orderItems: const <Product, OrderItem>{},
      );
    } else {
      //load existing order items
      final orderItemRepository = ref.read(orderItemRepositoryProvider);
      final orderItems = await orderItemRepository.getItemsByOrderId(order.id);
      final Map<Product, OrderItem> orderItemsMap = {};
      final productRepository = ref.read(productRepositoryProvider);
      for (final item in orderItems) {
        try {
          final product = await productRepository.read(item.productId);
          orderItemsMap[product] = item;
        } catch (e) {
          log('Error fetching product for order item: ${item.id}', error: e);
        }
      }

      state = state.copyWith(order: order, orderItems: orderItemsMap);
    }
  }

  bool get haveInitOrder {
    return state.order != null && state.order!.id != undefinedId;
  }

  void refreshDraftOrderList() {
    if (haveInitOrder) {
      ref.invalidate(orderListProvider(OrderStatus.draft));
    }
  }
}

@riverpod
class OrderDetail extends _$OrderDetail with CommonProvider<OrderState> {
  @override
  OrderState build(Order order) {
    Future(() async {
      //get lasted order items
      //
      final orderRepository = ref.read(orderRepositoryProvider);
      final lastedOrder = await orderRepository.read(order.id);

      final orderItemRepository = ref.read(orderItemRepositoryProvider);
      orderItemRepository.getItemsByOrderId(order.id).then((items) async {
        final productRepository = ref.read(productRepositoryProvider);
        final orderItems = <Product, OrderItem>{};
        for (final item in items) {
          final product = await productRepository.read(item.productId);
          orderItems[product] = item;
        }
        state = OrderState(order: lastedOrder, orderItems: orderItems);
      }).onError((error, stackTrace) {
        log('Error fetching order items', error: error, stackTrace: stackTrace);
        state = OrderState(order: lastedOrder, orderItems: {});
      });
    });
    return OrderState(order: order, orderItems: {});
  }

  Future createOrder() async {
    showLoading();

    final orderRepository = ref.read(orderRepositoryProvider);
    final order = await orderRepository.createOrder(
      state.order!.copyWith(
        status: OrderStatus.confirmed,
      ),
      state.orderItems.values.toList(),
    );

    state = state.copyWith(order: order);

    hideLoading();

    showSuccess(LKey.orderCreateSuccess.tr());
  }

  Future completeOrder() async {
    showLoading();

    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.completeOrder(state.order!);

    state = state.copyWith(order: order.copyWith(status: OrderStatus.done));

    hideLoading();

    showSuccess(
      LKey.orderCompleteSuccess.tr(
        namedArgs: {'orderId': '${state.order!.id}'},
      ),
    );
  }

  Future cancelOrder() async {
    showLoading();

    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.cancelOrder(state.order!);

    state = state.copyWith(order: order.copyWith(status: OrderStatus.cancelled));

    hideLoading();

    showSuccess(
      LKey.orderCancelSuccess.tr(
        namedArgs: {'orderId': '${state.order!.id}'},
      ),
    );
  }
}

@freezed
class OrderState with _$OrderState {
  const factory OrderState({
    Order? order,
    required Map<Product, OrderItem> orderItems,
    @Default(false) bool completeOnCreate,
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

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/order/order_repository.dart';
import '../../entities/order/order.dart';
import '../index.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(ref) => OrderRepositoryImpl();

@riverpod
OrderItemRepository orderItemRepository(ref) => OrderItemRepositoryImpl();

abstract class OrderRepository implements CrudRepository<Order, int> {
  Future<List<Order>> getOrdersByStatus(OrderStatus status);

  Future<Order> createOrder(Order order, List<OrderItem> items);
}

abstract class OrderItemRepository implements CrudRepository<OrderItem, int> {
  Future<List<OrderItem>> getItemsByOrderId(int orderId);
}

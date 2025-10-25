import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/order/order_repository.dart';
import '../../../provider/load_list.dart';
import '../../entities/order/order.dart';
import '../index.dart';
import '../product/update_product_repository.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) => OrderRepositoryImpl(
      ref.watch(updateProductRepositoryProvider),
    );

@riverpod
OrderItemRepository orderItemRepository(ref) => OrderItemRepositoryImpl();

abstract class OrderRepository implements CrudRepository<Order, int> {
  Future<LoadResult<Order>> getOrdersByStatus(
      OrderStatus status, LoadListQuery query);

  Future<List<Order>> getAllOrdersByStatus(OrderStatus status);

  Future<Order> createOrder(Order order, List<OrderItem> items);

  Future<void> deleteOrder(Order order);

  Future<void> completeOrder(Order oder);

  Future<void> cancelOrder(Order order);
}

abstract class OrderItemRepository implements CrudRepository<OrderItem, int> {
  Future<List<OrderItem>> getItemsByOrderId(int orderId);
}

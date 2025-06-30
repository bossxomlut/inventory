import '../../entities/order/order.dart';
import '../index.dart';

abstract class OrderRepository implements CrudRepository<Order, int> {
  Future<List<Order>> getOrdersByStatus(OrderStatus status);
}

abstract class OrderItemRepository implements CrudRepository<OrderItem, int> {
  Future<List<OrderItem>> getItemsByOrderId(int orderId);
}

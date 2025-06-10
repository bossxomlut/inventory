import '../../entities/order/order.dart';

abstract class OrderRepository {
  // Order CRUD operations
  Future<List<Order>> getAllOrders();
  Future<Order?> getOrderById(String id);
  Future<Order?> getOrderByNumber(String orderNumber);
  Future<List<Order>> getOrdersByStatus(OrderStatus status);
  Future<List<Order>> getOrdersByCustomer(String customerId);
  Future<Order> createOrder(Order order);
  Future<Order> updateOrder(Order order);
  Future<void> deleteOrder(String id);

  // Order search and filtering
  Future<List<Order>> searchOrders(String query);
  Future<List<Order>> getOrdersInDateRange(DateTime start, DateTime end);
  Future<List<Order>> getOrdersByCreator(String userId);

  // Customer CRUD operations
  Future<List<Customer>> getAllCustomers();
  Future<Customer?> getCustomerById(String id);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<List<Customer>> searchCustomers(String query);

  // Order number generation
  Future<String> generateOrderNumber();

  // Statistics
  Future<Map<OrderStatus, int>> getOrderCountByStatus();
  Future<double> getTotalSalesInDateRange(DateTime start, DateTime end);
}

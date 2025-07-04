import 'package:isar/isar.dart';

import '../../domain/entities/order/order.dart';
import '../../domain/repositories/order/order_repository.dart';
import '../database/isar_repository.dart';
import 'order.dart';

class OrderRepositoryImpl extends OrderRepository with IsarCrudRepository<Order, OrderCollection> {
  @override
  OrderCollection createNewItem(Order item) {
    return OrderCollection()
      ..id = item.id
      ..status = item.status
      ..createdAt = item.createdAt
      ..updatedAt = item.updatedAt
      ..totalPrice = item.totalPrice
      ..totalAmount = item.totalAmount
      ..orderDate = item.orderDate
      ..customerName = item.customer ?? ''
      ..customerContact = item.customerContact ?? ''
      ..note = item.note;
  }

  @override
  Future<Order> createOrder(Order order, List<OrderItem> items) {
    return isar.writeTxn(() async {
      final orderCollection = createNewItem(order);

      final orderId = await iCollection.put(orderCollection);

      final itemCollection = isar.collection<OrderItemCollection>();

      final orderItems = items.map((item) {
        return OrderItemCollection()
          ..orderId = orderId
          ..productId = item.productId
          ..productName = item.productName
          ..quantity = item.quantity
          ..price = item.price;
      }).toList();

      itemCollection.putAll(orderItems);

      return getItemFromCollection(orderCollection);
    });
  }

  @override
  int? getId(Order item) => item.id;

  @override
  Future<Order> getItemFromCollection(OrderCollection collection) {
    return Future.value(
      Order(
        id: collection.id,
        orderDate: collection.orderDate,
        customer: collection.customerName,
        customerContact: collection.customerContact,
        totalAmount: collection.totalAmount,
        totalPrice: collection.totalPrice,
        note: collection.note,
        status: collection.status,
        createdAt: collection.createdAt,
        updatedAt: collection.updatedAt,
        createdBy: collection.createdBy,
      ),
    );
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) {
    return iCollection.filter().statusEqualTo(status).findAll().then((collections) {
      return Future.wait(collections.map((collection) => getItemFromCollection(collection)));
    });
  }

  @override
  OrderCollection updateNewItem(Order item) {
    return OrderCollection()
      ..id = item.id
      ..orderDate = item.orderDate
      ..customerName = item.customer ?? ''
      ..customerContact = item.customerContact ?? ''
      ..totalAmount = item.totalAmount
      ..totalPrice = item.totalPrice
      ..note = item.note
      ..status = item.status
      ..createdBy = item.createdBy
      ..createdAt = item.createdAt
      ..updatedAt = DateTime.now();
  }
}

class OrderItemRepositoryImpl extends OrderItemRepository with IsarCrudRepository<OrderItem, OrderItemCollection> {
  @override
  OrderItemCollection createNewItem(OrderItem item) {
    return OrderItemCollection()
      ..id = item.id
      ..orderId = item.orderId
      ..productId = item.productId
      ..productName = item.productName
      ..quantity = item.quantity
      ..price = item.price;
  }

  @override
  int? getId(OrderItem item) => item.id;

  @override
  Future<OrderItem> getItemFromCollection(OrderItemCollection collection) {
    return Future.value(
      OrderItem(
        id: collection.id,
        orderId: collection.orderId,
        productId: collection.productId,
        productName: collection.productName,
        quantity: collection.quantity,
        price: collection.price,
      ),
    );
  }

  @override
  Future<List<OrderItem>> getItemsByOrderId(int orderId) {
    return iCollection.filter().orderIdEqualTo(orderId).findAll().then((collections) {
      return Future.wait(collections.map((collection) => getItemFromCollection(collection)));
    });
  }

  @override
  OrderItemCollection updateNewItem(OrderItem item) {
    return OrderItemCollection()
      ..id = item.id
      ..orderId = item.orderId
      ..productId = item.productId
      ..productName = item.productName
      ..quantity = item.quantity
      ..price = item.price;
  }
}

import 'package:isar/isar.dart';

import '../../domain/index.dart';
import '../../domain/repositories/order/order_repository.dart';
import '../../domain/repositories/product/update_product_repository.dart';
import '../../provider/load_list.dart';
import '../database/isar_repository.dart';
import 'order.dart';

class OrderRepositoryImpl extends OrderRepository with IsarCrudRepository<Order, OrderCollection> {
  OrderRepositoryImpl(this._updateProductRepository);

  final UpdateProductRepository _updateProductRepository;

  @override
  OrderCollection createNewItem(Order item) {
    return OrderCollection()
      ..status = item.status
      ..createdAt = item.createdAt
      ..updatedAt = item.updatedAt
      ..totalPrice = item.totalPrice
      ..productCount = item.productCount
      ..totalAmount = item.totalAmount
      ..orderDate = item.orderDate
      ..customerName = item.customer ?? ''
      ..customerContact = item.customerContact ?? ''
      ..createdBy = item.createdBy
      ..note = item.note;
  }

  @override
  Future<Order> createOrder(Order order, List<OrderItem> items) async {
    final createdOrder = await isar.writeTxn(() async {
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

    if (createdOrder.status == OrderStatus.confirmed) {
      //update product stock
      for (final item in items) {
        await _updateProductRepository.deductStock(
          item.productId,
          item.quantity,
          TransactionCategory.createOrder,
        );
      }
    }

    return createdOrder;
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
        productCount: collection.productCount,
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

  @override
  Future<LoadResult<Order>> getOrdersByStatus(OrderStatus status, LoadListQuery query) {
    return iCollection
        .filter()
        .statusEqualTo(status)
        .sortByOrderDateDesc()
        .offset((query.page - 1) * query.pageSize)
        .limit(query.pageSize)
        .findAll()
        .then((collections) {
      return Future.wait(collections.map((collection) => getItemFromCollection(collection))).then(
        (orders) => LoadResult(
          data: orders,
          totalCount: iCollection.filter().statusEqualTo(status).countSync(),
        ),
      );
    });
  }

  @override
  Future<void> deleteOrder(Order order) {
    final orderCollection = iCollection.getSync(order.id);

    //get existing order
    return isar.writeTxn(() async {
      if (orderCollection != null) {
        await iCollection.delete(order.id);
        //delete all order items
        final itemCollection = isar.collection<OrderItemCollection>();
        await itemCollection.filter().orderIdEqualTo(order.id).deleteAll();
      }
    });
  }

  @override
  Future<void> cancelOrder(Order order) async {
    final orderCollection = iCollection.getSync(order.id);

    isar.writeTxn(() async {
      if (orderCollection != null) {
        orderCollection.status = OrderStatus.cancelled;
        orderCollection.updatedAt = DateTime.now();
        await iCollection.put(orderCollection);
      }
    });

    //update product stock
    final itemCollection = isar.collection<OrderItemCollection>();
    final items = await itemCollection.filter().orderIdEqualTo(order.id).findAll();
    for (final item in items) {
      await _updateProductRepository.refillStock(item.productId, item.quantity, TransactionCategory.cancelOrder);
    }
    ;
  }

  @override
  Future<void> completeOrder(Order oder) {
    final orderCollection = iCollection.getSync(oder.id);

    return isar.writeTxn(() async {
      if (orderCollection != null) {
        orderCollection.status = OrderStatus.done;
        orderCollection.updatedAt = DateTime.now();
        await iCollection.put(orderCollection);
      }
    });
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

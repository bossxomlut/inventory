import 'package:isar_community/isar.dart';

import '../../domain/index.dart';
import '../../domain/repositories/order/order_repository.dart';
import '../../domain/repositories/product/update_product_repository.dart';
import '../../provider/load_list.dart';
import '../database/isar_repository.dart';
import 'order.dart';

class OrderRepositoryImpl extends OrderRepository
    with IsarCrudRepository<Order, OrderCollection> {
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
    bool isUpdateFromDraft = order.id != undefinedId;

    final createdOrder = await isar.writeTxn(() async {
      final orderCollection =
          isUpdateFromDraft ? updateNewItem(order) : createNewItem(order);

      final orderId = await iCollection.put(orderCollection);

      final itemCollection = isar.collection<OrderItemCollection>();

      final orderItems = items.map((item) {
        final orderItem = OrderItemCollection()
          ..orderId = orderId
          ..productId = item.productId
          ..productName = item.productName
          ..quantity = item.quantity
          ..price = item.price;

        if (item.id != undefinedId && order.status == OrderStatus.confirmed) {
          orderItem.id = item.id; // Preserve the ID if updating
        }

        return orderItem;
      }).toList();

      itemCollection.putAll(orderItems);

      return getItemFromCollection(orderCollection);
    });

    if (createdOrder.status == OrderStatus.confirmed) {
      final allocationCollection =
          isar.collection<OrderLotAllocationCollection>();
      final allocationRecords = <OrderLotAllocationCollection>[];

      for (final item in items) {
        final deductionResult = await _updateProductRepository.deductStock(
          item.productId,
          item.quantity,
          TransactionCategory.createOrder,
        );

        if (deductionResult.hasAllocations) {
          allocationRecords.addAll(
            deductionResult.allocations.map(
              (allocation) => OrderLotAllocationCollection()
                ..orderId = createdOrder.id
                ..productId = allocation.productId
                ..lotId = allocation.lotId
                ..quantity = allocation.quantity
                ..expiryDate = allocation.expiryDate
                ..manufactureDate = allocation.manufactureDate
                ..lotCreatedAt = allocation.createdAt
                ..lotUpdatedAt = allocation.updatedAt,
            ),
          );
        }
      }

      if (allocationRecords.isNotEmpty) {
        await isar.writeTxn(() async {
          await allocationCollection.putAll(allocationRecords);
        });
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
      ..productCount = item.productCount
      ..totalAmount = item.totalAmount
      ..totalPrice = item.totalPrice
      ..note = item.note
      ..status = item.status
      ..createdBy = item.createdBy
      ..createdAt = item.createdAt
      ..updatedAt = DateTime.now();
  }

  @override
  Future<LoadResult<Order>> getOrdersByStatus(
      OrderStatus status, LoadListQuery query) {
    final baseQuery =
        iCollection.filter().statusEqualTo(status).sortByOrderDateDesc();
    final offset = (query.page - 1) * query.pageSize;
    final keyword = query.search?.trim();

    if (keyword == null || keyword.isEmpty) {
      return baseQuery
          .offset(offset)
          .limit(query.pageSize)
          .findAll()
          .then((collections) async {
        final orders = await Future.wait(
          collections.map((collection) => getItemFromCollection(collection)),
        );
        final totalCount =
            await iCollection.filter().statusEqualTo(status).count();
        return LoadResult(data: orders, totalCount: totalCount);
      });
    }

    return baseQuery.findAll().then((collections) async {
      final searchText = keyword.toLowerCase();
      final searchId = int.tryParse(keyword);

      final filtered = collections.where((collection) {
        final customerMatch =
            collection.customerName.toLowerCase().contains(searchText);
        final contactMatch =
            collection.customerContact.toLowerCase().contains(searchText);
        final note = collection.note?.toLowerCase() ?? '';
        final noteMatch = note.contains(searchText);
        final idMatch = searchId != null && collection.id == searchId;
        return customerMatch || contactMatch || noteMatch || idMatch;
      }).toList();

      final totalCount = filtered.length;
      final paged = filtered.skip(offset).take(query.pageSize).toList();
      final orders = await Future.wait(
        paged.map((collection) => getItemFromCollection(collection)),
      );
      return LoadResult(data: orders, totalCount: totalCount);
    });
  }

  @override
  Future<List<Order>> getAllOrdersByStatus(OrderStatus status) async {
    final collections = await iCollection
        .filter()
        .statusEqualTo(status)
        .sortByOrderDateDesc()
        .findAll();
    return Future.wait(
      collections.map((collection) => getItemFromCollection(collection)),
    );
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

    await isar.writeTxn(() async {
      if (orderCollection != null) {
        orderCollection.status = OrderStatus.cancelled;
        orderCollection.updatedAt = DateTime.now();
        await iCollection.put(orderCollection);
      }
    });

    //update product stock
    final itemCollection = isar.collection<OrderItemCollection>();
    final items =
        await itemCollection.filter().orderIdEqualTo(order.id).findAll();
    final allocationCollection =
        isar.collection<OrderLotAllocationCollection>();
    for (final item in items) {
      final allocations = (await allocationCollection
              .filter()
              .orderIdEqualTo(order.id)
              .and()
              .productIdEqualTo(item.productId)
              .findAll())
          .map((e) => InventoryLotAllocation(
                productId: e.productId,
                lotId: e.lotId,
                quantity: e.quantity,
                expiryDate: e.expiryDate,
                manufactureDate: e.manufactureDate,
                createdAt: e.lotCreatedAt,
                updatedAt: e.lotUpdatedAt,
              ))
          .toList();
      await _updateProductRepository.refillStock(
        item.productId,
        item.quantity,
        TransactionCategory.cancelOrder,
        allocations: allocations,
      );
    }
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

class OrderItemRepositoryImpl extends OrderItemRepository
    with IsarCrudRepository<OrderItem, OrderItemCollection> {
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
    return iCollection
        .filter()
        .orderIdEqualTo(orderId)
        .findAll()
        .then((collections) {
      return Future.wait(
          collections.map((collection) => getItemFromCollection(collection)));
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

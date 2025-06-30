//create order collection

import 'package:isar/isar.dart';

import '../../domain/index.dart';

part 'order.g.dart';

@collection
class OrderCollection {
  Id id = Isar.autoIncrement;
  late String orderId; // Unique identifier for the order
  late DateTime orderDate; // Date when the order was placed
  late String customerName; // Name of the customer
  late String customerContact; // Contact information of the customer
  late double totalAmount; // Total amount for the order
  late double totalPrice; // Total price of the order including taxes and discounts
  String? note; // Optional note for the order
  @enumerated
  late OrderStatus status;
}

@collection
class OrderItemCollection {
  Id id = Isar.autoIncrement;
  late int productId; // Unique identifier for the product
  late String productName; // Name of the product
  late int quantity; // Quantity of the product ordered
  late double price; // Price of the product at the time of order

  final IsarLink<OrderCollection> order = IsarLink<OrderCollection>();
}

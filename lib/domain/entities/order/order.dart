import '../index.dart';

part 'order.freezed.dart';

enum OrderStatus {
  draft, // Order is pending
  confirmed, // Order is confirmed
  done,
  cancelled, // Order has been cancelled
}

// Order status extensions for UI
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.draft:
        return 'Nháp';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.done:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    required OrderStatus status,
    required DateTime orderDate,
    required DateTime createdAt,
    required String createdBy,
    required int productCount,
    required int totalAmount,
    required double totalPrice,
    DateTime? updatedAt,
    String? customer,
    String? customerContact,
    String? note,
    double? discount,
  }) = _Order;
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required int id,
    required int orderId, // Unique identifier for the product
    required int productId, // Unique identifier for the product
    required String productName, // Name of the product
    required int quantity, // Quantity of the product ordered
    required double price, // Price of the product at the time of order
  }) = _OrderItem;
}

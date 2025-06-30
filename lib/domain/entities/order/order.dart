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
    required String orderNumber,
    required OrderStatus status,
    required DateTime createdAt,
    required String createdBy,
    DateTime? updatedAt,
    String? customer, // Ignored for now as it wasn't defined
    String? note,
    double? discount,
  }) = _Order;
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required Product product,
    required int quantity, // Quantity of the product ordered
    required double price, // Price of the product at the time of order
  }) = _OrderItem;
}

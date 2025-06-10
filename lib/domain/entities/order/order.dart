import '../product/inventory.dart';

// Enum for order status
enum OrderStatus {
  draft, // Nháp - đang soạn thảo
  pending, // Chờ xử lý
  confirmed, // Đã xác nhận
  processing, // Đang xử lý
  shipped, // Đã gửi hàng
  delivered, // Đã giao hàng
  cancelled, // Đã hủy
  returned // Đã trả hàng
}

// Order status extensions for UI
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.draft:
        return 'Nháp';
      case OrderStatus.pending:
        return 'Chờ xử lý';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipped:
        return 'Đã gửi hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Đã trả hàng';
    }
  }

  bool get canEdit => this == OrderStatus.draft || this == OrderStatus.pending;
  bool get canCancel => this == OrderStatus.draft || this == OrderStatus.pending || this == OrderStatus.confirmed;
  bool get isActive => this != OrderStatus.cancelled && this != OrderStatus.delivered && this != OrderStatus.returned;
}

// Model for Order Item (single product in an order)
class OrderItem {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final String? notes;

  const OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  double get totalPrice => quantity * unitPrice;

  OrderItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
    String? notes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          product == other.product &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice &&
          notes == other.notes;

  @override
  int get hashCode => id.hashCode ^ product.hashCode ^ quantity.hashCode ^ unitPrice.hashCode ^ notes.hashCode;
}

// Model for Customer information
class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          email == other.email &&
          address == other.address &&
          notes == other.notes;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ phone.hashCode ^ email.hashCode ^ address.hashCode ^ notes.hashCode;
}

// Main Order model
class Order {
  final String id;
  final String orderNumber;
  final Customer? customer;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String? notes;
  final double? discount;
  final double? shippingCost;

  const Order({
    required this.id,
    required this.orderNumber,
    this.customer,
    required this.items,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.notes,
    this.discount,
    this.shippingCost,
  });

  // Computed properties
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get discountAmount => discount ?? 0.0;
  double get shippingAmount => shippingCost ?? 0.0;
  double get total => subtotal - discountAmount + shippingAmount;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get canEdit => status.canEdit;
  bool get canCancel => status.canCancel;

  Order copyWith({
    String? id,
    String? orderNumber,
    Customer? customer,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? notes,
    double? discount,
    double? shippingCost,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
      discount: discount ?? this.discount,
      shippingCost: shippingCost ?? this.shippingCost,
    );
  }

  // Add item to order
  Order addItem(OrderItem item) {
    final existingIndex = items.indexWhere((i) => i.product.id == item.product.id);
    List<OrderItem> newItems;

    if (existingIndex >= 0) {
      // Update existing item quantity
      newItems = [...items];
      newItems[existingIndex] = newItems[existingIndex].copyWith(
        quantity: newItems[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      newItems = [...items, item];
    }

    return copyWith(
      items: newItems,
      updatedAt: DateTime.now(),
    );
  }

  // Remove item from order
  Order removeItem(String itemId) {
    return copyWith(
      items: items.where((item) => item.id != itemId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Update item in order
  Order updateItem(String itemId, OrderItem updatedItem) {
    final newItems = items.map((item) {
      return item.id == itemId ? updatedItem : item;
    }).toList();

    return copyWith(
      items: newItems,
      updatedAt: DateTime.now(),
    );
  }

  // Update order status
  Order updateStatus(OrderStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderNumber == other.orderNumber &&
          customer == other.customer &&
          items == other.items &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          createdBy == other.createdBy &&
          notes == other.notes &&
          discount == other.discount &&
          shippingCost == other.shippingCost;

  @override
  int get hashCode =>
      id.hashCode ^
      orderNumber.hashCode ^
      customer.hashCode ^
      items.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      createdBy.hashCode ^
      notes.hashCode ^
      discount.hashCode ^
      shippingCost.hashCode;
}

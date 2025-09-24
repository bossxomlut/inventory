import 'inventory.dart';

class InventoryLotAllocation {
  const InventoryLotAllocation({
    required this.lotId,
    required this.productId,
    required this.quantity,
    required this.expiryDate,
    this.manufactureDate,
    this.createdAt,
    this.updatedAt,
  });

  final int lotId;
  final int productId;
  final int quantity;
  final DateTime expiryDate;
  final DateTime? manufactureDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InventoryLot toInventoryLot({int? quantityOverride}) {
    return InventoryLot(
      id: lotId,
      productId: productId,
      quantity: quantityOverride ?? quantity,
      expiryDate: expiryDate,
      manufactureDate: manufactureDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  InventoryLotAllocation copyWith({
    int? quantity,
  }) {
    return InventoryLotAllocation(
      lotId: lotId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate,
      manufactureDate: manufactureDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

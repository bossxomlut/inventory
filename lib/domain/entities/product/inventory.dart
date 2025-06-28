import 'package:freezed_annotation/freezed_annotation.dart';

import '../image.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

// Enum cho loại giao dịch
enum TransactionType { import, export, check }

// Enum cho trạng thái phiếu kiểm kê
enum InventoryCheckStatus { inProgress, completed }

// Enum cho trạng thái kiểm kê sản phẩm
enum CheckStatus {
  match, // Actual quantity matches expected
  surplus, // Actual quantity is higher than expected
  shortage, // Actual quantity is lower than expected
}

// Model cho Danh mục (Category)
@freezed
class Category with _$Category {
  const factory Category({
    required int id, // Mã danh mục
    required String name, // Tên danh mục
    String? description, // Mô tả (tùy chọn)
    DateTime? createDate, // Ngày tạo
    DateTime? updatedDate, // Ngày cập nhật
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

// Model cho Đơn vị (Unit)
@freezed
class Unit with _$Unit {
  const factory Unit({
    required int id,
    required String name,
    String? description,
    DateTime? createDate,
    DateTime? updatedDate,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}

// Model cho Sản phẩm (Product)
@freezed
class Product with _$Product {
  const factory Product({
    required int id, // Mã sản phẩm
    required String name, // Tên sản phẩm
    required int quantity, // Số lượng tồn kho
    double? price, // Giá sản phẩm
    String? barcode, // Mã vạch (tùy chọn)
    Category? category, // ID danh mục
    Unit? unit, // Đơn vị
    List<ImageStorageModel>? images, // URL ảnh (tùy chọn)
    String? description, // Mô tả (tùy chọn)
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

// Model cho Giao dịch (Transaction)
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id, // Mã giao dịch
    required String productId, // ID sản phẩm
    required int quantity, // Số lượng
    required TransactionType type, // Loại giao dịch
    required DateTime timestamp, // Thời gian giao dịch
    required String userId, // ID người thực hiện
    String? checkId, // ID phiếu kiểm kê (nếu là giao dịch kiểm kê)
    String? notes, // Ghi chú
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

// Model cho Phiếu kiểm kê (InventoryCheck)
@freezed
class InventoryCheck with _$InventoryCheck {
  const factory InventoryCheck({
    required String id, // ID phiếu kiểm kê
    required DateTime checkDate, // Ngày kiểm kê
    required String createdBy, // Người tạo phiếu kiểm
    required String checkedBy, // Người kiểm kê
    @Default(InventoryCheckStatus.inProgress) InventoryCheckStatus status, // Trạng thái
    String? notes, // Ghi chú
  }) = _InventoryCheck;

  factory InventoryCheck.fromJson(Map<String, dynamic> json) => _$InventoryCheckFromJson(json);
}

// Model cho từng mục trong phiếu kiểm kê
@freezed
class InventoryCheckItem with _$InventoryCheckItem {
  const factory InventoryCheckItem({
    required String id, // ID mục kiểm kê
    required String checkId, // ID phiếu kiểm kê
    required String productId, // ID sản phẩm
    required int currentQuantity, // Số lượng hiện tại
    required int newQuantity, // Số lượng mới
    String? notes, // Ghi chú
    DateTime? checkedAt, // Thời điểm kiểm kê
    String? transactionId, // ID giao dịch nếu đã cập nhật
  }) = _InventoryCheckItem;

  factory InventoryCheckItem.fromJson(Map<String, dynamic> json) => _$InventoryCheckItemFromJson(json);
}

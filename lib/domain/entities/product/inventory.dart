import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../image.dart';
import '../get_id.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

// Enum cho loại giao dịch
enum TransactionType { import, export }

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
class Unit with _$Unit implements GetIdX<int> {
  const factory Unit({
    required int id,
    required String name,
    String? description,
    DateTime? createDate,
    DateTime? updatedDate,
  }) = _Unit;
  
  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  
  const Unit._();
  
  @override
  int get getId => id;
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
  }) = _Transaction;
  
  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory.freezed.dart';

// Enum cho loại giao dịch
enum TransactionType { import, export }

// // Converter để xử lý TransactionType trong JSON
// class TransactionTypeConverter implements JsonConverter<TransactionType, int> {
//   const TransactionTypeConverter();
//
//   @override
//   TransactionType fromJson(int json) => TransactionType.values[json];
//
//   @override
//   int toJson(TransactionType object) => object.index;
// }

// Model cho Danh mục (Category)
@freezed
class Category with _$Category {
  const factory Category({
    required String id, // Mã danh mục
    required String name, // Tên danh mục
    String? description, // Mô tả (tùy chọn)
  }) = _Category;
}

// Model cho Sản phẩm (Product)
@freezed
class Product with _$Product {
  const factory Product({
    required String id, // Mã sản phẩm
    required String name, // Tên sản phẩm
    String? barcode, // Mã vạch (tùy chọn)
    required double price, // Giá sản phẩm
    required int quantity, // Số lượng tồn kho
    required String categoryId, // ID danh mục
    String? imageUrl, // URL ảnh (tùy chọn)
    String? description, // Mô tả (tùy chọn)
  }) = _Product;
}

// Model cho Kho hàng (Warehouse)
@freezed
class Warehouse with _$Warehouse {
  const factory Warehouse({
    required String id, // Mã kho
    required String name, // Tên kho
    required String location, // Vị trí kho
    @Default([]) List<String> productIds, // Danh sách ID sản phẩm
  }) = _Warehouse;
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
}

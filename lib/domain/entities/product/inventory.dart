import '../image.dart';
import '../index.dart';
import '../unit/unit.dart';

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
    required int id, // Mã danh mục
    required String name, // Tên danh mục
    String? description, // Mô tả (tùy chọn)
    DateTime? createDate, // Ngày tạo
    DateTime? updatedDate, // Ngày cập nhật
  }) = _Category;
}

// Model cho Sản phẩm (Product)
class Product {
  final int id; // Mã sản phẩm
  final String name; // Tên sản phẩm
  final int quantity; // Số lượng tồn kho
  final double? price; // Giá sản phẩm
  final String? barcode; // Mã vạch (tùy chọn)
  final Category? category; // ID danh mục
  final Unit? unit; // Đơn vị
  final List<ImageStorageModel>? images; // URL ảnh (tùy chọn)
  final String? description; // Mô tả (tùy chọn)

  const Product({
    required this.id,
    required this.name,
    required this.quantity,
    this.price,
    this.barcode,
    this.category,
    this.unit,
    this.images,
    this.description,
  });

  Product copyWith({
    int? id,
    String? name,
    int? quantity,
    double? price,
    String? barcode,
    Category? category,
    Unit? unit,
    List<ImageStorageModel>? images,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      images: images ?? this.images,
      description: description ?? this.description,
    );
  }
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

import 'package:isar/isar.dart';

import '../../domain/entities/product/inventory.dart';
import '../image/image.dart';

part 'inventory.g.dart';

@collection
class ProductCollection {
  Id id = Isar.autoIncrement;
  late String name;
  late String? barcode;
  late int quantity;
  final IsarLink<CategoryCollection> category = IsarLink<CategoryCollection>();
  final IsarLink<UnitCollection> unit = IsarLink<UnitCollection>();
  final IsarLinks<ImageStorageCollection> images = IsarLinks<ImageStorageCollection>();
  late String? description;
  late DateTime createdAt;
  late DateTime updatedAt;
}

@collection
class CategoryCollection {
  Id id = Isar.autoIncrement;
  late String name;
  late String? description;
  DateTime? createDate;
  DateTime? updatedDate;
}

@collection
class UnitCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? description;

  DateTime? createDate;

  DateTime? updatedDate;
}

@collection
class TransactionCollection {
  Id id = Isar.autoIncrement;

  // Liên kết với sản phẩm
  @Index()
  late int productId;

  // Số lượng giao dịch
  late int quantity;

  // Loại giao dịch: sử dụng enum để rõ ràng hơn
  @enumerated
  late TransactionType type;

  // Thời gian giao dịch
  @Index(type: IndexType.value)
  late DateTime timestamp;

  // Loại giao dịch bổ sung (nếu cần phân loại chi tiết hơn)
  @enumerated
  late TransactionCategory category;
}

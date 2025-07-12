class SampleProduct {
  final int id;
  final String name;
  final String categoryName;
  final String unitName;
  final double price;
  final int quantity;
  final String? description;
  final String? barcode;

  const SampleProduct({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.unitName,
    required this.price,
    required this.quantity,
    this.description,
    this.barcode,
  });

  factory SampleProduct.fromJson(Map<String, dynamic> json) {
    return SampleProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryName: json['categoryName'] as String? ?? '',
      unitName: json['unitName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      description: json['description'] as String?,
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryName': categoryName,
      'unitName': unitName,
      'price': price,
      'quantity': quantity,
      'description': description,
      'barcode': barcode,
    };
  }
}

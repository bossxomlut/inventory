class ShopType {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String dataFile;

  const ShopType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.dataFile,
  });

  static const List<ShopType> predefinedTypes = [
    ShopType(
      id: 'grocery_store',
      name: 'Cửa hàng tạp hóa',
      description: 'Các sản phẩm thiết yếu hàng ngày như gạo, mì, dầu ăn, đồ uống...',
      icon: '🏪',
      dataFile: 'assets/data/shop_types/grocery_store.jsonl',
    ),
    ShopType(
      id: 'bookstore',
      name: 'Cửa hàng văn phòng phẩm',
      description: 'Các dụng cụ học tập và văn phòng như bút, sổ, giấy, máy tính...',
      icon: '📚',
      dataFile: 'assets/data/shop_types/bookstore.jsonl',
    ),
    ShopType(
      id: 'coffee_shop',
      name: 'Cửa hàng cà phê',
      description: 'Nguyên liệu và dụng cụ cho quán cà phê như cà phê, trà, bánh ngọt...',
      icon: '☕',
      dataFile: 'assets/data/shop_types/coffee_shop.jsonl',
    ),
    ShopType(
      id: 'convenience_store',
      name: 'Cửa hàng tiện lợi',
      description: 'Các sản phẩm tiện ích và vệ sinh cá nhân hàng ngày...',
      icon: '🛒',
      dataFile: 'assets/data/shop_types/convenience_store.jsonl',
    ),
  ];
}

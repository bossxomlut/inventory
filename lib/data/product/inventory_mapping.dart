//mapping from category to category collection

import '../../domain/index.dart';
import '../image/image.dart';
import '../shared/mapping_data.dart';
import 'inventory.dart';

class CategoryMapping extends Mapping<Category?, CategoryCollection?> {
  @override
  Category? from(CategoryCollection? input) {
    if (input == null) {
      return null;
    }

    return Category(
      id: input.id,
      name: input.name,
      description: input.description,
    );
  }
}

class CategoryCollectionMapping extends Mapping<CategoryCollection?, Category?> {
  @override
  CategoryCollection? from(Category? input) {
    if (input == null) {
      return null;
    }

    return CategoryCollection()
      ..id = input.id
      ..name = input.name
      ..description = input.description;
  }
}

class ProductMapping extends Mapping<Product, ProductCollection> {
  @override
  Product from(ProductCollection input) {
    return Product(
      id: input.id,
      name: input.name,
      description: input.description,
      price: input.price,
      quantity: input.quantity,
      category: CategoryMapping().from(input.category.value),
      barcode: input.barcode,
      images: input.images.map((image) => ImageStorageModelMapping().from(image)).toList(),
    );
  }
}

class ProductCollectionMapping extends Mapping<ProductCollection, Product> {
  @override
  ProductCollection from(Product input) {
    return ProductCollection()
      ..id = input.id
      ..name = input.name
      ..description = input.description
      ..price = input.price
      ..quantity = input.quantity
      ..category.value = CategoryCollectionMapping().from(input.category)
      ..barcode = input.barcode
      ..images.addAll(input.images?.map((e) => ImageStorageCollectionMapping().from(e)) ?? []);
  }
}

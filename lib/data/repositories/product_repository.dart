import 'package:isar/isar.dart';

import '../../domain/index.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../model/image.dart';
import '../model/inventory.dart';
import '../model/inventory_mapping.dart';
import 'isar_repository.dart';

class ProductRepositoryImpl extends ProductRepository with IsarCrudRepository<Product, ProductCollection> {
  @override
  int? getId(Product item) => item.id;

  @override
  Future<Product> getItemFromCollection(ProductCollection collection) async {
    return Product(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      price: collection.price,
      quantity: collection.quantity,
      category: CategoryMapping().from(collection.category.value),
      barcode: collection.barcode,
      images: collection.images.map((image) => ImageStorageModelMapping().from(image)).toList(),
    );
  }

  @override
  ProductCollection createNewItem(Product item) {
    final p = ProductCollection()
      ..name = item.name
      ..description = item.description
      ..price = item.price
      ..quantity = item.quantity
      ..category.value = CategoryCollectionMapping().from(item.category)
      ..barcode = item.barcode
      ..images.addAll(item.images?.map((e) => ImageStorageCollectionMapping().from(e)) ?? []);

    return p;
  }

  @override
  ProductCollection updateNewItem(Product item) {
    return ProductCollection()
      ..id = item.id // Assuming id is set for update
      ..name = item.name
      ..description = item.description
      ..price = item.price
      ..quantity = item.quantity
      ..category.value = CategoryCollectionMapping().from(item.category)
      ..barcode = item.barcode
      ..images.update(link: item.images?.map((e) => ImageStorageCollectionMapping().from(e)) ?? []);
  }

  @override
  Future<List<Product>> search(String keyword, int page, int limit) async {
    final results = await iCollection
        .filter()
        .nameContains(keyword, caseSensitive: false)
        .or()
        .barcodeContains(keyword, caseSensitive: false)
        .findAll();
    return results.skip((page - 1) * limit).take(limit).map((ProductCollection e) {
      return Product(
        id: e.id,
        name: e.name,
        description: e.description,
        price: e.price,
        quantity: e.quantity,
        category: CategoryMapping().from(e.category.value),
        barcode: e.barcode,
        images: e.images.map((image) => ImageStorageModelMapping().from(image)).toList(),
      );
    }).toList();
  }

  // @override
  // Future<Product> create(Product item) {
  //   final ProductCollection nItem = createNewItem(item);
  //
  //   final id = isar.writeTxnSync(() => iCollection.put(nItem));
  //   return read(id);
  // }
}

class CategoryRepositoryImpl extends CategoryRepository with IsarCrudRepository<Category, CategoryCollection> {
  @override
  int? getId(Category item) => item.id;

  @override
  Future<Category> getItemFromCollection(CategoryCollection collection) async {
    return Category(
      id: collection.id,
      name: collection.name,
      description: collection.description,
    );
  }

  @override
  CategoryCollection createNewItem(Category item) {
    return CategoryCollection()
      ..name = item.name
      ..description = item.description;
  }

  @override
  CategoryCollection updateNewItem(Category item) {
    return CategoryCollection()
      ..id = item.id // Assuming id is set for update
      ..name = item.name
      ..description = item.description;
  }

  @override
  Future<List<Category>> search(String keyword, int page, int limit) async {
    final results = await iCollection
        .filter()
        .nameContains(keyword)
        .or()
        .descriptionContains(keyword)
        .sortByName()
        .offset(page)
        .limit(limit)
        .findAll();

    return results.map(
      (CategoryCollection e) {
        return Category(
          id: e.id,
          name: e.name,
          description: e.description,
        );
      },
    ).toList();
  }
}

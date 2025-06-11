import 'package:isar/isar.dart';

import '../../domain/index.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../features/product/provider/product_filter_provider.dart';
import '../../provider/load_list.dart';
import '../database/isar_repository.dart';
import '../image/image.dart';
import 'inventory.dart';
import 'inventory_mapping.dart';

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
  Future<LoadResult<Product>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter}) async {
    final Iterable<int>? selectedCategoryIds = filter?['categoryIds'] as Iterable<int>?;
    final String sortType = filter?['sortType'] as String? ?? 'name';
    final ProductSortType productSortType =
        ProductSortType.values.firstWhere((e) => e.name == sortType, orElse: () => ProductSortType.none);

    final query = await iCollection
        .filter()
        .group(
          (QueryBuilder<ProductCollection, ProductCollection, QFilterCondition> q) {
            return q
                .nameContains(keyword, caseSensitive: false)
                .or()
                .barcodeContains(keyword, caseSensitive: false)
                .or()
                .descriptionContains(keyword, caseSensitive: false);
          },
        )
        .optional<QAfterFilterCondition>(
          selectedCategoryIds?.isNotEmpty ?? false,
          (q) => q.category(
              (q) => q.anyOf<int, ProductCollection>(selectedCategoryIds!, (q, element) => q.idEqualTo(element))),
        )
        .optional(true, (QueryBuilder<ProductCollection, ProductCollection, QAfterFilterCondition> q) {
          switch (productSortType) {
            case ProductSortType.nameAsc:
              return q.sortByName();
            case ProductSortType.nameDesc:
              return q.sortByNameDesc();
            case ProductSortType.quantityAsc:
              return q.sortByQuantity().thenByName();
            case ProductSortType.quantityDesc:
              return q.sortByQuantityDesc().thenByName();
            case ProductSortType.none:
              return q.sortByName();
          }
        });

    final results = (await query.offset((page - 1) * limit).limit(limit).findAll()).map((ProductCollection e) {
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

    return LoadResult<Product>(
      data: results,
      totalCount: await query.count(),
    );
  }
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
  Future<LoadResult<Category>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter}) async {
    final results = await iCollection
        .filter()
        .nameContains(keyword)
        .or()
        .descriptionContains(keyword)
        .offset(page)
        .limit(limit)
        .findAll();

    final list = results.map(
      (CategoryCollection e) {
        return Category(
          id: e.id,
          name: e.name,
          description: e.description,
        );
      },
    ).toList();
    return LoadResult<Category>(
      data: list,
      totalCount: results.length,
    );
  }

  @override
  Future<List<Category>> getAll() {
    return iCollection.where().findAll().then((value) {
      return value.map((e) {
        return Category(
          id: e.id,
          name: e.name,
          description: e.description,
        );
      }).toList();
    });
  }
}

class SearchProductRepositoryImpl extends SearchProductRepository {
  @override
  Future<LoadResult<Product>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter}) async {
    return LoadResult<Product>(
      data: [],
      totalCount: 0, // You might want to implement a way to get the total count
    );
  }

  @override
  Future<Product> searchByBarcode(String barcode) {
    // TODO: implement searchByBarcode
    throw UnimplementedError();
  }
}

// Extension để hỗ trợ sắp xếp động
extension on QueryBuilder<ProductCollection, ProductCollection, QAfterFilterCondition> {
  QueryBuilder<ProductCollection, ProductCollection, QAfterSortBy> sortByNameDynamic(bool isAscending) {
    return isAscending ? sortByName() : sortByNameDesc();
  }
}

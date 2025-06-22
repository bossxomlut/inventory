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
      unit: UnitMapping().from(collection.unit.value),
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
      ..unit.value = UnitCollectionMapping().from(item.unit)
      ..barcode = item.barcode
      ..images.addAll(item.images?.map((e) => ImageStorageCollectionMapping().from(e)) ?? [])
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    // We will set the unit link after creating the product
    return p;
  }

  @override
  Future<Product> create(Product item) async {
    final collection = createNewItem(item);
    final id = await isar.writeTxnSync(() => iCollection.putSync(collection));

    return read(id);
  }

  @override
  ProductCollection updateNewItem(Product item) {
    return ProductCollection()
      ..id = item.id // Assuming id is set for update
      ..name = item.name
      ..description = item.description
      ..price = item.price
      ..quantity = item.quantity
      ..barcode = item.barcode
      ..category.value = CategoryCollectionMapping().from(item.category)
      ..unit.value = UnitCollectionMapping().from(item.unit)
      ..images.addAll(item.images?.map((e) => ImageStorageCollectionMapping().from(e)) ?? [])
      ..updatedAt = DateTime.now();
  }

  @override
  Future<Product> update(Product item) async {
    //get product by id
    final pCollection = await iCollection.get(item.id);

    if (pCollection == null) {
      throw Exception('Product not found');
    }

    final collection = updateNewItem(item)..createdAt = pCollection.createdAt;

    final id = await isar.writeTxnSync(() {
      return iCollection.putSync(collection);
    });

    return read(id);
  }

  @override
  Future<LoadResult<Product>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter}) async {
    final Iterable<int>? selectedCategoryIds = filter?['categoryIds'] as Iterable<int>?;
    final Iterable<int>? selectedUnitIds = filter?['unitIds'] as Iterable<int>?;
    final String sortType = filter?['sortType'] as String? ?? 'name';

    // Get time filters
    final DateTime? createdStartDate = filter?['createdStartDate'] as DateTime?;
    final DateTime? createdEndDate = filter?['createdEndDate'] as DateTime?;
    final DateTime? updatedStartDate = filter?['updatedStartDate'] as DateTime?;
    final DateTime? updatedEndDate = filter?['updatedEndDate'] as DateTime?;

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
          createdStartDate != null && createdEndDate != null,
          (QueryBuilder<ProductCollection, ProductCollection, QAfterFilterCondition> q) =>
              q.createdAtBetween(createdStartDate!, createdEndDate!),
        )
        .optional<QAfterFilterCondition>(
          updatedStartDate != null && updatedEndDate != null,
          (QueryBuilder<ProductCollection, ProductCollection, QAfterFilterCondition> q) =>
              q.updatedAtBetween(updatedStartDate!, updatedEndDate!),
        )
        .optional<QAfterFilterCondition>(
          selectedCategoryIds?.isNotEmpty ?? false,
          (q) => q.category(
              (q) => q.anyOf<int, ProductCollection>(selectedCategoryIds!, (q, element) => q.idEqualTo(element))),
        )
        .optional<QAfterFilterCondition>(
          selectedUnitIds?.isNotEmpty ?? false,
          (q) => q.unit((q) => q.anyOf<int, ProductCollection>(selectedUnitIds!, (q, element) => q.idEqualTo(element))),
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

    final List<ProductCollection> queryResults = await query.offset((page - 1) * limit).limit(limit).findAll();

    // Filter results based on units
    List<ProductCollection> filteredResults = queryResults;
    if (selectedUnitIds?.isNotEmpty ?? false) {
      filteredResults = queryResults.where((product) {
        return product.unit.value != null && selectedUnitIds!.contains(product.unit.value!.id);
      }).toList();
    }

    final results = filteredResults.map((ProductCollection e) {
      return Product(
        id: e.id,
        name: e.name,
        description: e.description,
        price: e.price,
        quantity: e.quantity,
        category: CategoryMapping().from(e.category.value),
        unit: e.unit.value != null
            ? Unit(
                id: e.unit.value!.id,
                name: e.unit.value!.name,
                description: e.unit.value!.description,
              )
            : null,
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

class CategoryRepositoryImpl extends CategoryRepository with IsarCrudRepository<Category, CategoryCollection> {
  @override
  int? getId(Category item) => item.id;

  @override
  Future<Category> getItemFromCollection(CategoryCollection collection) async {
    return Category(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      createDate: collection.createDate,
      updatedDate: collection.updatedDate,
    );
  }

  @override
  CategoryCollection createNewItem(Category item) {
    final now = DateTime.now();
    return CategoryCollection()
      ..name = item.name
      ..description = item.description
      ..createDate = now
      ..updatedDate = now;
  }

  @override
  CategoryCollection updateNewItem(Category item) {
    return CategoryCollection()
      ..id = item.id // Assuming id is set for update
      ..name = item.name
      ..description = item.description
      ..createDate = item.createDate
      ..updatedDate = DateTime.now();
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
          createDate: e.createDate,
          updatedDate: e.updatedDate,
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
          createDate: e.createDate,
          updatedDate: e.updatedDate,
        );
      }).toList();
    });
  }

  @override
  Future<List<Category>> searchAll(String keyword) {
    return iCollection
        .filter()
        .group(
          (QueryBuilder<CategoryCollection, CategoryCollection, QFilterCondition> q) {
            return q
                .nameContains(keyword, caseSensitive: false)
                .or()
                .descriptionContains(keyword, caseSensitive: false);
          },
        )
        .findAll()
        .then((value) {
          return value.map((e) {
            return Category(
              id: e.id,
              name: e.name,
              description: e.description,
              createDate: e.createDate,
              updatedDate: e.updatedDate,
            );
          }).toList();
        });
  }
}

class UnitRepositoryImpl implements UnitRepository {
  final Isar _isar = Isar.getInstance()!;

  IsarCollection<UnitCollection> get iCollection => _isar.collection<UnitCollection>();

  @override
  Future<Unit> create(Unit unit) async {
    final now = DateTime.now();
    final unitWithDates = unit.copyWith(createDate: now, updatedDate: now);

    final collection = UnitCollection()
      ..name = unitWithDates.name
      ..description = unitWithDates.description
      ..createDate = unitWithDates.createDate
      ..updatedDate = unitWithDates.updatedDate;

    final id = await _isar.writeTxn(() => iCollection.put(collection));
    return unitWithDates.copyWith(id: id);
  }

  @override
  Future<bool> delete(Unit unit) async {
    return await _isar.writeTxn(() => iCollection.delete(unit.id));
  }

  @override
  Future<Unit> read(int id) async {
    final collection = await iCollection.get(id);
    if (collection == null) {
      throw Exception('Unit not found');
    }

    return Unit(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      createDate: collection.createDate,
      updatedDate: collection.updatedDate,
    );
  }

  @override
  Future<Unit> update(Unit unit) async {
    final unitWithDate = unit.copyWith(updatedDate: DateTime.now());

    final collection = UnitCollection()
      ..id = unitWithDate.id
      ..name = unitWithDate.name
      ..description = unitWithDate.description
      ..createDate = unitWithDate.createDate
      ..updatedDate = unitWithDate.updatedDate;

    await _isar.writeTxn(() => iCollection.put(collection));
    return unitWithDate;
  }

  @override
  Future<List<Unit>> getAll() async {
    final collections = await iCollection.where().findAll();
    return collections
        .map((collection) => Unit(
              id: collection.id,
              name: collection.name,
              description: collection.description,
              createDate: collection.createDate,
              updatedDate: collection.updatedDate,
            ))
        .toList();
  }

  @override
  Future<Unit> getById(int id) async {
    final collection = await iCollection.get(id);
    if (collection == null) {
      throw Exception('Unit not found');
    }

    return Unit(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      createDate: collection.createDate,
      updatedDate: collection.updatedDate,
    );
  }

  @override
  Future<LoadResult<Unit>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter}) async {
    final allCollections = await iCollection.where().findAll();

    final filteredCollections = keyword.isEmpty
        ? allCollections
        : allCollections
            .where((c) =>
                c.name.toLowerCase().contains(keyword.toLowerCase()) ||
                (c.description?.toLowerCase().contains(keyword.toLowerCase()) ?? false))
            .toList();

    // Sort by name
    filteredCollections.sort((a, b) => a.name.compareTo(b.name));

    // Implement simple pagination in memory
    final start = (page - 1) * limit;
    final end = start + limit < filteredCollections.length ? start + limit : filteredCollections.length;

    final List<UnitCollection> paginatedCollections =
        start < filteredCollections.length ? filteredCollections.sublist(start, end) : <UnitCollection>[];

    final units = paginatedCollections
        .map((collection) => Unit(
              id: collection.id as int,
              name: collection.name as String,
              description: collection.description as String?,
              createDate: collection.createDate,
              updatedDate: collection.updatedDate,
            ))
        .toList();

    return LoadResult<Unit>(
      data: units,
      totalCount: filteredCollections.length,
    );
  }

  @override
  Future<List<Unit>> searchAll(String keyword) {
    return iCollection
        .filter()
        .group(
          (QueryBuilder<UnitCollection, UnitCollection, QFilterCondition> q) {
            return q
                .nameContains(keyword, caseSensitive: false)
                .or()
                .descriptionContains(keyword, caseSensitive: false);
          },
        )
        .findAll()
        .then((value) {
          return value.map((e) {
            return Unit(
              id: e.id,
              name: e.name,
              description: e.description,
              createDate: e.createDate,
              updatedDate: e.updatedDate,
            );
          }).toList();
        });
  }
}

// Extension để hỗ trợ sắp xếp động
extension on QueryBuilder<ProductCollection, ProductCollection, QAfterFilterCondition> {
  QueryBuilder<ProductCollection, ProductCollection, QAfterSortBy> sortByNameDynamic(bool isAscending) {
    return isAscending ? sortByName() : sortByNameDesc();
  }
}

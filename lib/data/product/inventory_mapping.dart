//mapping from category to category collection

import '../../domain/entities/index.dart';
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
      createDate: input.createDate,
      updatedDate: input.updatedDate,
    );
  }
}

class CategoryCollectionMapping
    extends Mapping<CategoryCollection?, Category?> {
  @override
  CategoryCollection? from(Category? input) {
    if (input == null) {
      return null;
    }

    return CategoryCollection()
      ..id = input.id
      ..name = input.name
      ..description = input.description
      ..createDate = input.createDate
      ..updatedDate = input.updatedDate;
  }
}

//unit mapping
class UnitMapping extends Mapping<Unit?, UnitCollection?> {
  @override
  Unit? from(UnitCollection? input) {
    if (input == null) {
      return null;
    }

    return Unit(
      id: input.id,
      name: input.name,
      description: input.description,
      createDate: input.createDate,
      updatedDate: input.updatedDate,
    );
  }
}

class UnitCollectionMapping extends Mapping<UnitCollection?, Unit?> {
  @override
  UnitCollection? from(Unit? input) {
    if (input == null) {
      return null;
    }

    return UnitCollection()
      ..id = input.id
      ..name = input.name
      ..description = input.description
      ..createDate = input.createDate
      ..updatedDate = input.updatedDate;
  }
}

class ProductMapping extends Mapping<Product, ProductCollection> {
  @override
  Product from(ProductCollection input) {
    Unit? unit = null;
    if (input.unit.value != null) {
      unit = Unit(
        id: input.unit.value!.id,
        name: input.unit.value!.name,
        description: input.unit.value!.description,
        createDate: input.unit.value!.createDate,
        updatedDate: input.unit.value!.updatedDate,
      );
    }

    return Product(
      id: input.id,
      name: input.name,
      description: input.description,
      quantity: input.quantity,
      category: CategoryMapping().from(input.category.value),
      unit: unit,
      barcode: input.barcode,
      images: input.images
          .map((image) => ImageStorageModelMapping().from(image))
          .toList(),
      enableExpiryTracking: input.enableExpiryTracking,
      lots: input.lots.map((lot) => InventoryLotMapping().from(lot)).toList(),
    );
  }
}

class ProductCollectionMapping extends Mapping<ProductCollection, Product> {
  @override
  ProductCollection from(Product input) {
    final collection = ProductCollection()
      ..id = input.id
      ..name = input.name
      ..description = input.description
      ..quantity = input.quantity
      ..enableExpiryTracking = input.enableExpiryTracking
      ..category.value = CategoryCollectionMapping().from(input.category)
      ..barcode = input.barcode
      ..images.addAll(
          input.images?.map((e) => ImageStorageCollectionMapping().from(e)) ??
              []);

    // We don't set the unit link here because it requires async operations
    // The unit link will be set in the repository's create/update methods

    return collection;
  }
}

class InventoryLotMapping
    extends Mapping<InventoryLot, InventoryLotCollection> {
  @override
  InventoryLot from(InventoryLotCollection input) {
    return InventoryLot(
      id: input.id,
      productId: input.productId,
      quantity: input.quantity,
      expiryDate: input.expiryDate,
      manufactureDate: input.manufactureDate,
      createdAt: input.createdAt,
      updatedAt: input.updatedAt,
    );
  }
}

class InventoryLotCollectionMapping
    extends Mapping<InventoryLotCollection, InventoryLot> {
  @override
  InventoryLotCollection from(InventoryLot input) {
    return InventoryLotCollection()
      ..id = input.id
      ..productId = input.productId
      ..quantity = input.quantity
      ..expiryDate = input.expiryDate
      ..manufactureDate = input.manufactureDate
      ..createdAt = input.createdAt ?? DateTime.now()
      ..updatedAt = input.updatedAt ?? DateTime.now();
  }
}

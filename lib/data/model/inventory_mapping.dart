//mapping from category to category collection

import '../../domain/index.dart';
import 'inventory.dart';
import 'mapping_data.dart';

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

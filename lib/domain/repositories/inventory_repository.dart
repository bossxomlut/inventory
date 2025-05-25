import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/product_repository.dart';
import '../index.dart';
import 'crud_repository.dart';

part 'inventory_repository.g.dart';

@riverpod
ProductRepository productRepository(ref) => ProductRepositoryImpl();

//basic repository to manage product
abstract class ProductRepository implements CrudRepository<Product, int>, SearchRepositoryWithPagination<Product> {}

@riverpod
CategoryRepository categoryRepository(ref) => CategoryRepositoryImpl();

abstract class CategoryRepository implements CrudRepository<Category, int>, SearchRepositoryWithPagination<Category> {}

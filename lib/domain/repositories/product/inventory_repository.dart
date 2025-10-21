import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/product/product_repository.dart';
import '../../../data/product/search_expiry_product_repository.dart';
import '../../index.dart';
import '../crud_repository.dart';

part 'inventory_repository.g.dart';

@riverpod
ProductRepository productRepository(ref) => ProductRepositoryImpl();

@riverpod
SearchProductRepository searchProductRepository(ref) =>
    SearchProductRepositoryImpl();

@riverpod
SearchExpiryProductRepository searchExpiryProductRepository(ref) =>
    SearchExpiryProductRepositoryImpl();

//basic repository to manage product
abstract class ProductRepository
    implements
        CrudRepository<Product, int>,
        SearchRepositoryWithPagination<Product> {}

abstract class SearchProductRepository
    implements SearchRepositoryWithPagination<Product> {
  Future<Product> searchByBarcode(String barcode);
}

abstract class SearchExpiryProductRepository
    implements SearchRepositoryWithPagination<Product> {
  Future<ProductExpirySummary> expirySummary(
    String keyword,
    Map<String, dynamic>? filter, {
    int soonThresholdDays = 7,
  });
}

@riverpod
CategoryRepository categoryRepository(ref) => CategoryRepositoryImpl();

abstract class CategoryRepository
    implements
        CrudRepository<Category, int>,
        SearchRepositoryWithPagination<Category>,
        GetAllRepository<Category>,
        SearchRepository<Category>,
        SearchByName<Category> {}

final unitRepositoryProvider =
    Provider<UnitRepository>((ref) => UnitRepositoryImpl());

abstract class UnitRepository
    implements
        CrudRepository<Unit, int>,
        SearchRepositoryWithPagination<Unit>,
        GetAllRepository<Unit>,
        SearchRepository<Unit>,
        SearchByName<Unit> {}

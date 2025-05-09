import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../index.dart';
import 'crud_repository.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(ref) => ProductRepositoryImpl();

//basic repository to manage product
abstract class ProductRepository implements CrudRepository<Product, String>, SearchRepositoryWithPagination<Product> {}

class ProductRepositoryImpl implements ProductRepository {
  //static list to simulate a database
  static List<Product> _products = [
    Product(
      id: 'id',
      name: 'name',
      price: 1,
      quantity: 1,
      categoryId: '1',
    ),
  ];

  @override
  Future<Product> create(Product item) async {
    _products.add(item);
    return item;
  }

  @override
  Future<Product> read(String id) async {
    return _products.firstWhere(
      (product) => product.id == id,
      orElse: () {
        throw NotFoundException('Product with id ${id} not found');
      },
    );
  }

  @override
  Future<Product> update(Product item) async {
    final index = _products.indexWhere((product) => product.id == item.id);
    if (index != -1) {
      _products[index] = item;
      return item;
    }
    throw Exception('Product not found');
  }

  @override
  Future<bool> delete(Product item) async {
    final index = _products.indexWhere((product) => product.id == item.id);
    if (index != -1) {
      _products.removeAt(index);
      return true;
    }
    return false;
  }

  @override
  Future<List<Product>> search(String keyword, int page, int limit) async {
    // Simulate a search operation
    return _products.where((product) => product.name.contains(keyword)).skip((page - 1) * limit).take(limit).toList();
  }
}

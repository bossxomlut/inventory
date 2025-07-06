import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/product/update_product_repository.dart';
import '../../entities/product/inventory.dart';
import 'inventory_repository.dart';
import 'transaction_repository.dart';

part 'update_product_repository.g.dart';

@riverpod
UpdateProductRepository updateProductRepository(Ref ref) => UpdateProductRepositoryImpl(
      productRepository: ref.read(productRepositoryProvider),
      transactionRepository: ref.read(transactionRepositoryProvider),
    );

abstract class UpdateProductRepository {
  Future<Product> createProduct(Product product);

  Future<Product> updateProduct(Product product, TransactionCategory category);

  Future<void> deductStock(int productId, int quantity, TransactionCategory category);

  Future<void> refillStock(int productId, int quantity, TransactionCategory category);
}

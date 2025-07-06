import '../../domain/entities/get_id.dart';
import '../../domain/entities/product/inventory.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../domain/repositories/product/transaction_repository.dart';
import '../../domain/repositories/product/update_product_repository.dart';

class UpdateProductRepositoryImpl implements UpdateProductRepository {
  UpdateProductRepositoryImpl({
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
  })  : _productRepository = productRepository,
        _transactionRepository = transactionRepository;

  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;

  @override
  Future<Product> updateProduct(Product product, TransactionCategory category) async {
    final existProduct = await _productRepository.read(product.id);

    final updatedProduct = await _productRepository.update(product);

    final differenceQuantity = product.quantity - existProduct.quantity;

    await _transactionRepository.create(
      Transaction(
        id: undefinedId,
        productId: updatedProduct.id,
        quantity: differenceQuantity.abs(),
        type: TransactionType.fromDifference(differenceQuantity),
        category: category,
        timestamp: DateTime.now(),
      ),
    );

    return updatedProduct;
  }

  @override
  Future<Product> createProduct(Product product) async {
    final updatedProduct = await _productRepository.create(product);

    await _transactionRepository.create(
      Transaction(
        id: undefinedId,
        productId: updatedProduct.id,
        quantity: product.quantity,
        type: TransactionType.increase,
        category: TransactionCategory.create,
        timestamp: DateTime.now(),
      ),
    );

    return updatedProduct;
  }

  @override
  Future<void> refillStock(int productId, int quantity, TransactionCategory category) async {
    final existProduct = await _productRepository.read(productId);
    if (existProduct == null) {
      throw Exception('Product with id $productId does not exist');
    }

    final updatedProduct = await _productRepository.update(
      existProduct.copyWith(quantity: existProduct.quantity + quantity),
    );

    await _transactionRepository.create(
      Transaction(
        id: undefinedId,
        productId: updatedProduct.id,
        quantity: quantity,
        type: TransactionType.increase,
        category: category,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deductStock(int productId, int quantity, TransactionCategory category) {
    return _productRepository.read(productId).then((existProduct) {
      if (existProduct == null) {
        throw Exception('Product with id $productId does not exist');
      }

      return _productRepository
          .update(
        existProduct.copyWith(quantity: existProduct.quantity - quantity),
      )
          .then((updatedProduct) {
        return _transactionRepository.create(
          Transaction(
            id: undefinedId,
            productId: updatedProduct.id,
            quantity: quantity,
            type: TransactionType.decrease,
            category: category,
            timestamp: DateTime.now(),
          ),
        );
      });
    });
  }
}

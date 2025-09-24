import '../../domain/entities/get_id.dart';
import '../../domain/entities/product/inventory.dart';
import '../../domain/entities/product/inventory_lot_allocation.dart';
import '../../domain/exceptions/crud_exceptions.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../domain/repositories/product/transaction_repository.dart';
import '../../domain/repositories/product/update_product_repository.dart';
import '../../domain/services/product/inventory_lot_service.dart';

class UpdateProductRepositoryImpl implements UpdateProductRepository {
  UpdateProductRepositoryImpl({
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
    required InventoryLotService inventoryLotService,
  })  : _productRepository = productRepository,
        _transactionRepository = transactionRepository,
        _inventoryLotService = inventoryLotService;

  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;
  final InventoryLotService _inventoryLotService;

  @override
  Future<Product> updateProduct(
      Product product, TransactionCategory category) async {
    final existProduct = await _productRepository.read(product.id);

    final sanitizedLots =
        product.lots.where((lot) => lot.quantity > 0).toList(growable: false);
    final updatedProduct = await _productRepository.update(
      product.copyWith(lots: sanitizedLots),
    );

    Product finalProduct = updatedProduct;
    int finalQuantity = updatedProduct.quantity;

    if (product.enableExpiryTracking && sanitizedLots.isEmpty) {
      final clearedResult = await _inventoryLotService.clearLots(
        product: updatedProduct,
        transactionCategory: TransactionCategory.lotUpdate,
      );
      finalProduct = clearedResult.product;
      finalQuantity = clearedResult.totalQuantity;
    } else if (product.enableExpiryTracking) {
      final syncResult = await _inventoryLotService.syncLots(
        product: updatedProduct,
        desiredLots: sanitizedLots,
        transactionCategory: TransactionCategory.lotUpdate,
      );
      finalProduct = syncResult.product;
      finalQuantity = syncResult.totalQuantity;
    } else if (existProduct.enableExpiryTracking) {
      final clearedResult = await _inventoryLotService.clearLots(
        product: updatedProduct,
        transactionCategory: TransactionCategory.lotUpdate,
      );
      finalProduct = clearedResult.product;
      finalQuantity = finalProduct.quantity;
    }

    final differenceQuantity = finalQuantity - existProduct.quantity;

    await _transactionRepository.create(
      Transaction(
        id: undefinedId,
        productId: finalProduct.id,
        quantity: differenceQuantity.abs(),
        type: TransactionType.fromDifference(differenceQuantity),
        category: category,
        timestamp: DateTime.now(),
      ),
    );

    return finalProduct;
  }

  @override
  Future<Product> createProduct(Product product) async {
    final bool trackLots = product.enableExpiryTracking &&
        product.lots.any((lot) => lot.quantity > 0);
    final sanitizedLots =
        product.lots.where((lot) => lot.quantity > 0).toList(growable: false);
    final int totalQuantity = trackLots
        ? sanitizedLots.fold<int>(0, (sum, lot) => sum + lot.quantity)
        : product.quantity;

    final productToSave = product.copyWith(
      quantity: totalQuantity,
      lots: sanitizedLots,
    );

    final createdProduct = await _productRepository.create(productToSave);

    Product finalProduct = createdProduct;

    if (trackLots) {
      final syncResult = await _inventoryLotService.syncLots(
        product: createdProduct,
        desiredLots: sanitizedLots,
        transactionCategory: TransactionCategory.lotUpdate,
      );
      finalProduct = syncResult.product;
    } else if (product.enableExpiryTracking && sanitizedLots.isEmpty) {
      final clearedResult = await _inventoryLotService.clearLots(
        product: createdProduct,
        transactionCategory: TransactionCategory.lotUpdate,
      );
      finalProduct = clearedResult.product;
    }

    await _transactionRepository.create(
      Transaction(
        id: undefinedId,
        productId: finalProduct.id,
        quantity: finalProduct.quantity,
        type: TransactionType.increase,
        category: TransactionCategory.create,
        timestamp: DateTime.now(),
      ),
    );

    return finalProduct;
  }

  @override
  Future<void> refillStock(
    int productId,
    int quantity,
    TransactionCategory category, {
    List<InventoryLotAllocation> allocations = const [],
  }) async {
    final existProduct = await _productRepository.read(productId);
    if (quantity <= 0) {
      throw ValidationException('Số lượng bổ sung phải lớn hơn 0.');
    }

    if (allocations.isNotEmpty) {
      final allocatedQuantity =
          allocations.fold<int>(0, (sum, allocation) => sum + allocation.quantity);
      if (allocatedQuantity != quantity) {
        throw ValidationException('Số lượng lô không khớp với số lượng cần hoàn.');
      }

      await _inventoryLotService.restoreAllocations(
        product: existProduct,
        allocations: allocations,
        transactionCategory: category,
      );

      return;
    }

    if (existProduct.enableExpiryTracking) {
      throw ValidationException(
          'Vui lòng điều chỉnh số lượng theo từng lô đối với sản phẩm đang quản lý hạn sử dụng.');
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
  Future<StockDeductionResult> deductStock(
      int productId, int quantity, TransactionCategory category) async {
    if (quantity <= 0) {
      throw ValidationException('Số lượng trừ phải lớn hơn 0.');
    }

    final existProduct = await _productRepository.read(productId);

    if (quantity > existProduct.quantity) {
      throw ValidationException('Số lượng cần trừ vượt quá tồn kho hiện có.');
    }

    if (existProduct.enableExpiryTracking) {
      final outcome = await _inventoryLotService.deductFromNearestExpiry(
        product: existProduct,
        quantity: quantity,
        transactionCategory: category,
      );

      return StockDeductionResult(
        productId: productId,
        quantity: quantity,
        allocations: outcome.allocations,
      );
    }

    final updatedProduct = await _productRepository.update(
      existProduct.copyWith(quantity: existProduct.quantity - quantity),
    );

    await _transactionRepository.create(
      Transaction(
        id: undefinedId,
        productId: updatedProduct.id,
        quantity: quantity,
        type: TransactionType.decrease,
        category: category,
        timestamp: DateTime.now(),
      ),
    );

    return StockDeductionResult(
      productId: productId,
      quantity: quantity,
      allocations: const [],
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../entities/get_id.dart';
import '../../entities/product/inventory.dart';
import '../../entities/product/inventory_lot_allocation.dart';
import '../../exceptions/crud_exceptions.dart';
import '../../repositories/product/inventory_lot_repository.dart';
import '../../repositories/product/inventory_repository.dart';
import '../../repositories/product/transaction_repository.dart';

part 'inventory_lot_service.g.dart';

@riverpod
InventoryLotService inventoryLotService(InventoryLotServiceRef ref) =>
    InventoryLotService(
      lotRepository: ref.read(inventoryLotRepositoryProvider),
      productRepository: ref.read(productRepositoryProvider),
      transactionRepository: ref.read(transactionRepositoryProvider),
    );

class InventoryLotService {
  InventoryLotService({
    required InventoryLotRepository lotRepository,
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
  })  : _lotRepository = lotRepository,
        _productRepository = productRepository,
        _transactionRepository = transactionRepository;

  final InventoryLotRepository _lotRepository;
  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;

  Future<InventoryLotSyncResult> syncLots({
    required Product product,
    required List<InventoryLot> desiredLots,
    required TransactionCategory transactionCategory,
  }) async {
    _validateLots(desiredLots);

    final sanitizedLots = desiredLots.map((lot) {
      final normalizedId = lot.id <= 0 ? undefinedId : lot.id;
      return lot.copyWith(
        id: normalizedId,
        productId: product.id,
        createdAt: normalizedId == undefinedId ? null : lot.createdAt,
        updatedAt: null,
      );
    }).toList();

    final existingLots = await _lotRepository.getLotsByProduct(product.id);
    final existingMap = {for (final lot in existingLots) lot.id: lot};
    final desiredIds = sanitizedLots
        .where((lot) => lot.id != undefinedId)
        .map((lot) => lot.id)
        .toSet();

    final updates = sanitizedLots
        .where(
            (lot) => lot.id != undefinedId && existingMap.containsKey(lot.id))
        .toList();
    final creations =
        sanitizedLots.where((lot) => lot.id == undefinedId).toList();
    final deletions = existingLots
        .where((existing) => !desiredIds.contains(existing.id))
        .toList();

    final now = DateTime.now();

    final shouldLogTransactions =
        transactionCategory != TransactionCategory.lotUpdate;

    for (final lot in updates) {
      final previous = existingMap[lot.id]!;
      final updated = await _lotRepository.update(
        lot.copyWith(
          createdAt: previous.createdAt,
        ),
      );

      final quantityDifference = updated.quantity - previous.quantity;
      final metadataChanged = updated.expiryDate != previous.expiryDate ||
          updated.manufactureDate != previous.manufactureDate;

      if (shouldLogTransactions &&
          (quantityDifference != 0 || metadataChanged)) {
        await _transactionRepository.create(
          Transaction(
            id: undefinedId,
            productId: product.id,
            quantity: quantityDifference.abs(),
            type: TransactionType.fromDifference(quantityDifference),
            category: transactionCategory,
            timestamp: now,
            inventoryLotId: updated.id,
          ),
        );
      }
    }

    if (deletions.isNotEmpty) {
      for (final lot in deletions) {
        if (shouldLogTransactions) {
          await _transactionRepository.create(
            Transaction(
              id: undefinedId,
              productId: product.id,
              quantity: lot.quantity,
              type: TransactionType.decrease,
              category: transactionCategory,
              timestamp: now,
              inventoryLotId: lot.id,
            ),
          );
        }
      }

      await _lotRepository.deleteLotsByIds(deletions.map((lot) => lot.id));
    }

    for (final lot in creations) {
      final created = await _lotRepository.create(lot);

      if (shouldLogTransactions) {
        await _transactionRepository.create(
          Transaction(
            id: undefinedId,
            productId: product.id,
            quantity: created.quantity,
            type: TransactionType.increase,
            category: transactionCategory,
            timestamp: now,
            inventoryLotId: created.id,
          ),
        );
      }
    }

    final finalLots = await _lotRepository.getLotsByProduct(product.id);
    final totalQuantity =
        finalLots.fold<int>(0, (sum, lot) => sum + lot.quantity);

    Product updatedProduct = product;
    if (product.quantity != totalQuantity || !product.enableExpiryTracking) {
      updatedProduct = await _productRepository.update(
        product.copyWith(
          quantity: totalQuantity,
          enableExpiryTracking: true,
        ),
      );
    }

    final refreshed = await _productRepository.read(product.id);

    return InventoryLotSyncResult(
      product: refreshed,
      lots: finalLots,
      totalQuantity: totalQuantity,
    );
  }

  Future<InventoryLotDeductionOutcome> deductFromNearestExpiry({
    required Product product,
    required int quantity,
    required TransactionCategory transactionCategory,
  }) async {
    if (quantity <= 0) {
      throw ValidationException('Quantity to deduct must be greater than 0.');
    }

    final lots = await _lotRepository.getLotsByProduct(product.id);

    if (lots.isEmpty) {
      throw ValidationException('No inventory lots available to deduct.');
    }

    final totalQuantity = lots.fold<int>(0, (sum, lot) => sum + lot.quantity);

    if (quantity > totalQuantity) {
      throw ValidationException(
        'Requested deduction exceeds the current stock quantity.',
      );
    }

    final now = DateTime.now();
    var remaining = quantity;
    final lotsToUpdate = <InventoryLot>[];
    final lotsToDelete = <int>[];
    final transactions = <Transaction>[];
    final allocations = <InventoryLotAllocation>[];

    for (final lot in lots) {
      if (remaining <= 0) {
        break;
      }

      if (lot.quantity <= 0) {
        continue;
      }

      final deduction = remaining < lot.quantity ? remaining : lot.quantity;
      if (deduction <= 0) {
        continue;
      }

      final newQuantity = lot.quantity - deduction;
      remaining -= deduction;

      allocations.add(
        InventoryLotAllocation(
          lotId: lot.id,
          productId: product.id,
          quantity: deduction,
          expiryDate: lot.expiryDate,
          manufactureDate: lot.manufactureDate,
          createdAt: lot.createdAt,
          updatedAt: lot.updatedAt,
        ),
      );

      if (newQuantity == 0) {
        lotsToDelete.add(lot.id);
      } else {
        lotsToUpdate.add(
          lot.copyWith(
            quantity: newQuantity,
            updatedAt: now,
          ),
        );
      }

      transactions.add(
        Transaction(
          id: undefinedId,
          productId: product.id,
          quantity: deduction,
          type: TransactionType.decrease,
          category: transactionCategory,
          timestamp: now,
          inventoryLotId: lot.id,
        ),
      );
    }

    if (remaining > 0) {
      throw ValidationException('Không đủ tồn kho để trừ hàng.');
    }

    for (final lot in lotsToUpdate) {
      await _lotRepository.update(lot);
    }

    if (lotsToDelete.isNotEmpty) {
      await _lotRepository.deleteLotsByIds(lotsToDelete);
    }

    for (final transaction in transactions) {
      await _transactionRepository.create(transaction);
    }

    final refreshedLots = await _lotRepository.getLotsByProduct(product.id);
    final finalQuantity =
        refreshedLots.fold<int>(0, (sum, lot) => sum + lot.quantity);

    final updatedProduct = await _productRepository.update(
      product.copyWith(quantity: finalQuantity),
    );

    final refreshedProduct = await _productRepository.read(updatedProduct.id);

    return InventoryLotDeductionOutcome(
      result: InventoryLotSyncResult(
        product: refreshedProduct,
        lots: refreshedLots,
        totalQuantity: finalQuantity,
      ),
      allocations: allocations,
    );
  }

  Future<InventoryLotSyncResult> restoreAllocations({
    required Product product,
    required List<InventoryLotAllocation> allocations,
    required TransactionCategory transactionCategory,
  }) async {
    if (allocations.isEmpty) {
      return InventoryLotSyncResult(
        product: product,
        lots: await _lotRepository.getLotsByProduct(product.id),
        totalQuantity: product.quantity,
      );
    }

    final now = DateTime.now();

    for (final allocation in allocations) {
      InventoryLot? existingLot;

      try {
        existingLot = await _lotRepository.read(allocation.lotId);
      } on NotFoundException {
        existingLot = null;
      }

      if (existingLot != null && existingLot.productId == product.id) {
        final updatedLot = existingLot.copyWith(
          quantity: existingLot.quantity + allocation.quantity,
          updatedAt: now,
        );
        await _lotRepository.update(updatedLot);
      } else {
        final restoredLot = allocation.toInventoryLot(
          quantityOverride: allocation.quantity,
        );
        await _lotRepository.create(
          restoredLot.copyWith(
            productId: product.id,
            quantity: allocation.quantity,
            createdAt: allocation.createdAt ?? now,
            updatedAt: now,
          ),
        );
      }

      await _transactionRepository.create(
        Transaction(
          id: undefinedId,
          productId: product.id,
          quantity: allocation.quantity,
          type: TransactionType.increase,
          category: transactionCategory,
          timestamp: now,
          inventoryLotId: allocation.lotId,
        ),
      );
    }

    final refreshedLots = await _lotRepository.getLotsByProduct(product.id);
    final totalQuantity =
        refreshedLots.fold<int>(0, (sum, lot) => sum + lot.quantity);

    final updatedProduct = await _productRepository.update(
      product.copyWith(
        quantity: totalQuantity,
        enableExpiryTracking: true,
      ),
    );

    final refreshedProduct = await _productRepository.read(updatedProduct.id);

    return InventoryLotSyncResult(
      product: refreshedProduct,
      lots: refreshedLots,
      totalQuantity: totalQuantity,
    );
  }

  Future<InventoryLotSyncResult> clearLots({
    required Product product,
    required TransactionCategory transactionCategory,
  }) async {
    final existingLots = await _lotRepository.getLotsByProduct(product.id);

    if (existingLots.isNotEmpty) {
      final now = DateTime.now();

      for (final lot in existingLots) {
        if (transactionCategory != TransactionCategory.lotUpdate) {
          await _transactionRepository.create(
            Transaction(
              id: undefinedId,
              productId: product.id,
              quantity: lot.quantity,
              type: TransactionType.decrease,
              category: transactionCategory,
              timestamp: now,
              inventoryLotId: lot.id,
            ),
          );
        }
      }

      await _lotRepository.deleteLotsByIds(existingLots.map((lot) => lot.id));
    }

    Product updatedProduct = product;
    if (product.enableExpiryTracking) {
      updatedProduct = await _productRepository.update(
        product.copyWith(enableExpiryTracking: false),
      );
    }

    final refreshed = await _productRepository.read(product.id);

    return InventoryLotSyncResult(
      product: refreshed,
      lots: const [],
      totalQuantity: refreshed.quantity,
    );
  }

  void _validateLots(List<InventoryLot> lots) {
    if (lots.isEmpty) {
      throw ValidationException('Vui lòng thêm ít nhất một lô hàng.');
    }

    final normalizedKeys = <String>{};

    for (final lot in lots) {
      if (lot.quantity <= 0) {
        throw ValidationException('Số lượng của mỗi lô phải lớn hơn 0.');
      }

      if (lot.manufactureDate != null &&
          lot.manufactureDate!.isAfter(lot.expiryDate)) {
        throw ValidationException('Ngày sản xuất không được sau ngày hết hạn.');
      }

      final key =
          '${lot.expiryDate.toIso8601String()}|${lot.manufactureDate?.toIso8601String() ?? 'null'}';
      if (!normalizedKeys.add(key)) {
        throw DuplicateEntryException(
            'Không thể có hai lô trùng cả ngày sản xuất và ngày hết hạn.');
      }
    }
  }
}

class InventoryLotSyncResult {
  InventoryLotSyncResult({
    required this.product,
    required this.lots,
    required this.totalQuantity,
  });

  final Product product;
  final List<InventoryLot> lots;
  final int totalQuantity;
}

class InventoryLotDeductionOutcome {
  InventoryLotDeductionOutcome({
    required this.result,
    required this.allocations,
  });

  final InventoryLotSyncResult result;
  final List<InventoryLotAllocation> allocations;
}

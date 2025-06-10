import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/check/check_repository.dart';
import '../../entities/check/check.dart';
import '../../index.dart';
import '../index.dart';
import '../product/inventory_repository.dart';

part 'check_repository.g.dart';

@riverpod
CheckRepository checkRepository(Ref ref) => CheckRepositoryImpl(
      checkSessionRepository: ref.watch(checkSessionRepositoryProvider),
      checkedProductRepository: ref.watch(checkedProductRepositoryProvider),
      searchProductRepository: ref.watch(searchProductRepositoryProvider),
    );

@riverpod
CheckSessionRepository checkSessionRepository(_) => CheckSessionRepositoryImpl();

@riverpod
CheckedProductRepository checkedProductRepository(_) => CheckedProductRepositoryImpl();

abstract class CheckRepository {
  Future<CheckSession> createSession(String name, String createdBy, {String? note});

  Future<CheckSession> updateSession(CheckSession session);

  Future<void> deleteSession(CheckSession session);

  Future<List<CheckSession>> getActiveSessions();

  Future<List<CheckSession>> getDoneSessions();

  Future<Product?> findProductByBarcode(String barcode);

  Future<List<Product>> searchProducts(String keyword, {int page = 1, int pageSize = 20});

  Future<CheckedProduct> addProductToSession(int sessionId, Product product, int actualQuantity, String checkedBy,
      {String? note});

  Future<List<CheckedProduct>> getChecksBySession(int sessionId);

  Future<CheckedProduct> updateInventoryCheck(CheckedProduct check);

  Future<void> deleteInventoryCheck(CheckedProduct check);
}

abstract class CheckSessionRepository implements CrudRepository<CheckSession, int> {
  Future<List<CheckSession>> getActiveSessions();

  Future<List<CheckSession>> getDoneSessions();
}

abstract class CheckedProductRepository
    implements CrudRepository<CheckedProduct, int>, SearchRepositoryWithPagination<CheckedProduct> {
  Future<List<CheckedProduct>> getChecksBySession(int sessionId);
}

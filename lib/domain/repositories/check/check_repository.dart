import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/check/check_repository.dart';
import '../../index.dart';
import '../index.dart';
import '../product/update_product_repository.dart';

part 'check_repository.g.dart';

@riverpod
CheckRepository checkRepository(Ref ref) => CheckRepositoryImpl(
      checkSessionRepository: ref.read(checkSessionRepositoryProvider),
      checkedProductRepository: ref.read(checkedProductRepositoryProvider),
      updateProductRepository: ref.read(updateProductRepositoryProvider),
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

  Future<CheckedProduct> addProductToSession(CheckSession session, Product product, int actualQuantity, {String? note});

  Future<List<CheckedProduct>> getChecksBySession(int sessionId);

  Future<CheckedProduct> updateInventoryCheck(CheckedProduct check);

  Future<void> deleteInventoryCheck(CheckedProduct check);
}

abstract class CheckSessionRepository implements CrudRepository<CheckSession, int> {
  Future<List<CheckSession>> getActiveSessions();

  Future<List<CheckSession>> getDoneSessions();
}

abstract class CheckedProductRepository
    implements
        CrudRepository<CheckedProduct, int>,
        SearchRepositoryWithPagination<CheckedProduct>,
        GetAllRepository<CheckedProduct> {
  Future<List<CheckedProduct>> getCheckedListBySession(int sessionId);
}

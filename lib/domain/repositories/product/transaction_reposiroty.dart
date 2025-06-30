import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/product/transaction_repository.dart';
import '../../entities/index.dart';
import '../index.dart';

part 'transaction_reposiroty.g.dart';

@riverpod
TransactionRepository transactionRepository(ref) => TransactionRepositoryImpl();

@riverpod
Future<List<Transaction>> getTransactionsByProductId(
  Ref ref,
  int productId,
) {
  return ref.read(transactionRepositoryProvider).getTransactionsByProductId(productId);
}

abstract class TransactionRepository implements CrudRepository<Transaction, int> {
  Future<List<Transaction>> getTransactionsByProductId(int productId);
}

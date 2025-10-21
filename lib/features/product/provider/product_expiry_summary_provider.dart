import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/product/product_expiry_summary.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';

part 'product_expiry_summary_provider.g.dart';

const int _defaultExpirySoonThresholdDays = 7;

@riverpod
Future<ProductExpirySummary> productExpirySummary(
    ProductExpirySummaryRef ref) async {
  final repository = ref.read(searchExpiryProductRepositoryProvider);

  return repository.expirySummary(
    '',
    null,
    soonThresholdDays: _defaultExpirySoonThresholdDays,
  );
}

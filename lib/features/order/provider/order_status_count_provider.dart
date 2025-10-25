import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../data/order/order.dart';
import '../../../domain/entities/order/order.dart';

/// Watches the number of orders for a given [OrderStatus] and keeps the UI
/// in sync regardless of active search filters or pagination.
final orderStatusCountProvider =
    StreamProvider.autoDispose.family<int, OrderStatus>((ref, status) async* {
  final isar = Isar.getInstance();
  if (isar == null) {
    yield 0;
    return;
  }

  final collection = isar.collection<OrderCollection>();

  Future<int> fetchCount() =>
      collection.filter().statusEqualTo(status).count();

  // Emit initial value.
  yield await fetchCount();

  // Re-emit whenever there are changes in the collection.
  await for (final _ in collection.watchLazy()) {
    yield await fetchCount();
  }
});

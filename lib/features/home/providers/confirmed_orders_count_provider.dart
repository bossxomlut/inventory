import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../data/order/order.dart';
import '../../../domain/entities/order/order.dart';

/// StreamProvider that emits the current count of orders with status `confirmed`.
/// It listens to Isar collection changes (watchLazy) and re-queries the count so
/// the UI badge remains synchronized automatically.
final confirmedOrdersCountProvider = StreamProvider.autoDispose<int>((ref) async* {
  final isar = Isar.getInstance()!;
  final collection = isar.collection<OrderCollection>();

  // Emit initial count
  final initialCount = collection.filter().statusEqualTo(OrderStatus.confirmed).countSync();
  yield initialCount;

  // Listen to collection changes and re-query count on each change
  await for (final _ in collection.watchLazy()) {
    final newCount = collection.filter().statusEqualTo(OrderStatus.confirmed).countSync();
    yield newCount;
  }
});

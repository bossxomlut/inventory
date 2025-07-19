import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/order/price_repository.dart';
import '../../entities/order/price.dart';
import '../index.dart';

part 'price_repository.g.dart';

@riverpod
PriceRepository priceRepository(ref) => PriceRepositoryImpl();

@riverpod
Future<ProductPrice> productPriceById(Ref ref, int id) async {
  final repository = ref.read(priceRepositoryProvider);
  return repository.getProductPriceByProductId(id);
}

abstract class PriceRepository implements CrudRepository<ProductPrice, int>, GetAllRepository<ProductPrice> {
  Future<ProductPrice> getProductPriceByProductId(int productId);
}

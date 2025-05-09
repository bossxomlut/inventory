import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/inventory.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../provider/load_list.dart';

final loadProductProvider = NotifierProvider<LoadProductController, LoadListState<Product>>(() {
  return LoadProductController.new();
});

class LoadProductController extends LoadListController<Product> {
  @override
  Future<List<Product>> fetchData(LoadListQuery query) {
    final productRepo = ref.watch(productRepositoryProvider);
    return productRepo.search(query.search ?? '', query.page, query.pageSize);
  }
}

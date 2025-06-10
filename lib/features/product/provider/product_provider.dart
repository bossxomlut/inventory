import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/helpers/app_image_manager.dart';
import '../../../domain/entities/get_id.dart';
import '../../../domain/entities/image.dart';
import '../../../domain/entities/product/inventory.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../routes/app_router.dart';
import 'product_filter_provider.dart';

final loadProductProvider = AutoDisposeNotifierProvider<LoadProductController, LoadListState<Product>>(() {
  return LoadProductController.new();
});

class LoadProductController extends LoadListController<Product> with CommonProvider<LoadListState<Product>> {
  //create a method to listen filter changes to call reload data

  void listenFilterChanges() {
    refresh();
  }

  @override
  Future<List<Product>> fetchData(LoadListQuery query) {
    final productRepo = ref.read(productRepositoryProvider);

    // Tạo filter từ các bộ lọc đã chọn
    final filter = ref.read(productFilterProvider);

    final search = filter['search'] as String? ?? '';

    print('Search query: $search');

    // Truyền filter xuống repository
    return productRepo.search(search, query.page, query.pageSize, filter: filter);
  }

  //create a product
  void createProduct(Product product) async {
    try {
      showLoading();
      final productRepo = ref.read(productRepositoryProvider);
      List<ImageStorageModel> savedImages = [];
      final AppImageManager appImageManager = AppImageManager();
      if (product.images != null && product.images!.isNotEmpty) {
        for (final img in product.images!) {
          // If the image has a path, assume it's already saved
          if (img.id == undefinedId) {
            final nImg = await appImageManager.saveImageFromPath(img.path!);
            savedImages.add(nImg);
          } else {
            savedImages.add(img);
          }
        }
      }
      final newProduct = product.copyWith(images: savedImages);
      final created = await productRepo.create(newProduct);
      state = state.copyWith(data: [...state.data, created]);
      showSuccess('Add new product successfully');
      appRouter.popForced();
    } catch (e) {
      //log error
      print('Error creating product: $e');
      // Handle error
      state = state.copyWith(error: e.toString());
      showError('Add new product failed');
    } finally {
      hideLoading();
    }
  }

  //update a product
  void updateProduct(Product product) async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final updatedProduct = await productRepo.update(product);
      state = state.copyWith(
        data: state.data.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList(),
      );
      showSuccess('Update product successfully');
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
      showError('Update product failed');
    }
  }
}

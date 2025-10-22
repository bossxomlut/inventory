import 'package:isar_community/isar.dart';

import '../../core/index.dart';
import '../../domain/entities/image.dart';
import '../../domain/repositories/index.dart';
import '../database/isar_repository.dart';
import 'image.dart';

class ImageStorageRepositoryImpl extends ImageStorageRepository
    with IsarCrudRepository<ImageStorageModel, ImageStorageCollection> {
  @override
  ImageStorageCollection createNewItem(ImageStorageModel item) {
    return ImageStorageCollection()..path = item.path;
  }

  @override
  Future<ImageStorageModel> getItemFromCollection(ImageStorageCollection collection) {
    return Future.value(
      ImageStorageModel(
        id: collection.id,
        path: collection.path,
      ),
    );
  }

  @override
  ImageStorageCollection updateNewItem(ImageStorageModel item) {
    return ImageStorageCollection()
      ..id = item.id
      ..path = item.path;
  }

  @override
  Future<List<ImageStorageModel>> getAll() {
    return iCollection.where().findAll().then((collections) {
      return mapListAsync(collections, getItemFromCollection);
    });
  }

  @override
  int? getId(ImageStorageModel item) {
    return item.id;
  }
}

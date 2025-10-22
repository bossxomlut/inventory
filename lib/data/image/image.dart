import 'package:isar_community/isar.dart';

import '../../domain/entities/image.dart';
import '../shared/mapping_data.dart';

part 'image.g.dart';

@collection
class ImageStorageCollection {
  Id id = Isar.autoIncrement;
  String? path;
}

//create a mapping from ImageStorageModel to ImageStorageCollection follow CategoryCollectionMapping
class ImageStorageModelMapping extends Mapping<ImageStorageModel, ImageStorageCollection> {
  @override
  ImageStorageModel from(ImageStorageCollection input) {
    return ImageStorageModel(
      id: input.id,
      path: input.path,
    );
  }
}

class ImageStorageCollectionMapping extends Mapping<ImageStorageCollection, ImageStorageModel> {
  @override
  ImageStorageCollection from(ImageStorageModel input) {
    return ImageStorageCollection()
      ..id = input.id
      ..path = input.path;
  }
}

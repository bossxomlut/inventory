import '../../data/repositories/image_storage_repository.dart';
import '../entities/image.dart';
import 'crud_repository.dart';

final ImageStorageRepository imageStorageRepository = ImageStorageRepositoryImpl();

abstract class ImageStorageRepository
    implements CrudRepository<ImageStorageModel, int>, GetAllRepository<ImageStorageModel> {
  static ImageStorageRepository instance = imageStorageRepository;
}

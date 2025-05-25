import 'package:image_picker/image_picker.dart';

import '../domain/entities/index.dart';

abstract class AppFilePicker {
  const AppFilePicker();

  // final FileType fileType;

  Future<AppFile?> pickOne();
  Future<List<AppFile>?> pickMultiFiles();

  factory AppFilePicker.image() {
    return ImageFilePicker();
  }

  factory AppFilePicker.camera() {
    return CameraFilePicker();
  }
}

class ImageFilePicker extends AppFilePicker {
  const ImageFilePicker();

  @override
  Future<AppFile?> pickOne() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      return AppFile(path: file.path, name: file.name);
    }
    return null;
  }

  @override
  Future<List<AppFile>?> pickMultiFiles() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? files = await picker.pickMultiImage();
    if (files != null && files.isNotEmpty) {
      return files.map((e) => AppFile(path: e.path, name: e.name)).toList();
    }
    return null;
  }
}

//camera
class CameraFilePicker extends AppFilePicker {
  const CameraFilePicker();

  @override
  Future<AppFile?> pickOne() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      return AppFile(path: file.path, name: file.name);
    }
    return null;
  }

  @override
  Future<List<AppFile>?> pickMultiFiles() async {}
}

//
// class VideoFilePicker extends AppFilePicker {
//   const VideoFilePicker({
//     super.key,
//     required super.allowMultiple,
//   }) : super(fileType: FileType.video);
// }
//
// class AudioFilePicker extends AppFilePicker {
//   const AudioFilePicker({
//     super.key,
//     required super.allowMultiple,
//   }) : super(fileType: FileType.audio);
// }
//
// class AnyFilePicker extends AppFilePicker {
//   const AnyFilePicker({
//     super.key,
//     required super.allowMultiple,
//   }) : super(fileType: FileType.any);
// }

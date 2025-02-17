import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/index.dart';

class AppFilePicker extends StatelessWidget {
  const AppFilePicker({Key? key, required this.allowMultiple}) : super(key: key);

  final bool allowMultiple;
  // final FileType fileType;

  Future<List<AppFile>?> opeFilePicker() {
    final ImagePicker picker = ImagePicker();

    return picker.pickMultiImage().then((value) {
      return value
          .map(
            (file) => AppFile(name: file.name, path: file.path),
          )
          .toList();
    }).onError(
      (error, StackTrace stackTrace) async {
        log('error: $error', stackTrace: stackTrace);
        return [];
      },
    );

    // return FilePicker.platform
    //     .pickFiles(
    //   type: fileType,
    //   allowMultiple: allowMultiple,
    //   withData: false,
    //   onFileLoading: (status) {
    //     print('status: $status');
    //   },
    // )
    //     .then((filePickerResult) {
    //   print('lol: ${filePickerResult?.files}');
    //
    //   return filePickerResult?.files
    //       .map(
    //         (file) => AppFile(name: file.name, path: file.path ?? ""),
    //       )
    //       .toList();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
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

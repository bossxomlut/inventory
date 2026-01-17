import 'package:google_sign_in/google_sign_in.dart';
import 'package:sample_app/core/use_case.dart';
import 'package:sample_app/services/google_drive_service.dart';

class DriveReadParams {
  DriveReadParams({
    required this.googleUser,
    required this.folderName,
    required this.filePrefix,
    this.fileId,
  });

  final GoogleSignInAccount googleUser;
  final String folderName;
  final String filePrefix;
  final String? fileId;
}

class DriveReadResult {
  DriveReadResult({
    required this.fileId,
    required this.content,
  });

  final String fileId;
  final String content;
}

class DriveReadFileUseCase
    extends FutureUseCase<DriveReadResult, DriveReadParams> {
  DriveReadFileUseCase(this._service);

  final GoogleDriveService _service;

  @override
  Future<DriveReadResult> execute(DriveReadParams input) async {
    final folderId = await _service.ensureFolderId(
      account: input.googleUser,
      folderName: input.folderName,
    );

    final fileId = input.fileId ??
        await _service.findLatestFileId(
          account: input.googleUser,
          folderId: folderId,
          namePrefix: input.filePrefix,
        );

    if (fileId == null || fileId.isEmpty) {
      throw StateError('Drive file not found in folder.');
    }

    final content = await _service.readTextFile(
      account: input.googleUser,
      fileId: fileId,
    );

    return DriveReadResult(fileId: fileId, content: content);
  }
}

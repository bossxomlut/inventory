import 'package:google_sign_in/google_sign_in.dart';
import 'package:sample_app/core/use_case.dart';
import 'package:sample_app/services/google_drive_service.dart';

class DriveWriteParams {
  DriveWriteParams({
    required this.googleUser,
    required this.folderName,
    required this.filePrefix,
    required this.content,
    this.userId,
  });

  final GoogleSignInAccount googleUser;
  final String folderName;
  final String filePrefix;
  final String content;
  final String? userId;
}

class DriveWriteResult {
  DriveWriteResult({
    required this.fileId,
    required this.fileName,
    required this.folderId,
  });

  final String fileId;
  final String fileName;
  final String folderId;
}

class DriveWriteFileUseCase
    extends FutureUseCase<DriveWriteResult, DriveWriteParams> {
  DriveWriteFileUseCase(this._service);

  final GoogleDriveService _service;

  @override
  Future<DriveWriteResult> execute(DriveWriteParams input) async {
    final folderId = await _service.ensureFolderId(
      account: input.googleUser,
      folderName: input.folderName,
    );
    final fileName = _buildFileName(
      prefix: input.filePrefix,
      userId: input.userId,
    );
    final file = await _service.writeTextFile(
      account: input.googleUser,
      folderId: folderId,
      fileName: fileName,
      content: input.content,
    );
    final fileId = file.id;
    if (fileId == null || fileId.isEmpty) {
      throw StateError('Drive file id missing after upload.');
    }
    return DriveWriteResult(
      fileId: fileId,
      fileName: fileName,
      folderId: folderId,
    );
  }

  String _buildFileName({
    required String prefix,
    required String? userId,
  }) {
    final uid = userId?.isNotEmpty == true ? userId! : 'unknown';
    final now = DateTime.now();
    final stamp =
        '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_'
        '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
    return '${prefix}_${uid}_$stamp.txt';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sample_app/core/use_case.dart';
import 'package:sample_app/services/google_drive_service.dart';

class DriveListFolderParams {
  DriveListFolderParams({
    required this.googleUser,
    required this.folderName,
  });

  final GoogleSignInAccount googleUser;
  final String folderName;
}

class DriveListItem {
  DriveListItem({
    required this.name,
    required this.isFolder,
  });

  final String name;
  final bool isFolder;
}

class DriveListFolderResult {
  DriveListFolderResult({
    required this.folderId,
    required this.items,
  });

  final String folderId;
  final List<DriveListItem> items;
}

class DriveListFolderUseCase
    extends FutureUseCase<DriveListFolderResult, DriveListFolderParams> {
  DriveListFolderUseCase(this._service);

  final GoogleDriveService _service;

  @override
  Future<DriveListFolderResult> execute(DriveListFolderParams input) async {
    final folderId = await _service.ensureFolderId(
      account: input.googleUser,
      folderName: input.folderName,
    );

    final files = await _service.listFolder(
      account: input.googleUser,
      folderId: folderId,
    );

    final items = files
        .map(
          (file) => DriveListItem(
            name: file.name ?? 'Unnamed',
            isFolder: file.mimeType == 'application/vnd.google-apps.folder',
          ),
        )
        .toList(growable: false);

    return DriveListFolderResult(folderId: folderId, items: items);
  }
}

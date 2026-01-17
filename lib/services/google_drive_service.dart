import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveService {
  Future<T> _withDriveApi<T>({
    required GoogleSignInAccount account,
    required List<String> scopes,
    required Future<T> Function(drive.DriveApi api) action,
  }) async {
    final auth = await account.authorizationClient.authorizeScopes(scopes);
    final client = auth.authClient(scopes: scopes);
    final api = drive.DriveApi(client);
    try {
      return await action(api);
    } finally {
      client.close();
    }
  }

  Future<String> ensureFolderId({
    required GoogleSignInAccount account,
    required String folderName,
  }) async {
    final existing = await _withDriveApi(
      account: account,
      scopes: <String>[
        drive.DriveApi.driveFileScope,
        drive.DriveApi.driveMetadataReadonlyScope,
      ],
      action: (api) => api.files.list(
        q:
            "name='$folderName' and mimeType='application/vnd.google-apps.folder' "
            "and trashed=false and 'root' in parents",
        $fields: 'files(id,name)',
        spaces: 'drive',
        pageSize: 1,
      ),
    );

    if (existing.files?.isNotEmpty == true) {
      return existing.files!.first.id!;
    }

    final created = await _withDriveApi(
      account: account,
      scopes: <String>[drive.DriveApi.driveFileScope],
      action: (api) => api.files.create(
        drive.File()
          ..name = folderName
          ..mimeType = 'application/vnd.google-apps.folder'
          ..parents = <String>['root'],
      ),
    );
    final folderId = created.id;
    if (folderId == null || folderId.isEmpty) {
      throw StateError('Drive folder id missing after creation.');
    }
    return folderId;
  }

  Future<drive.File> writeTextFile({
    required GoogleSignInAccount account,
    required String folderId,
    required String fileName,
    required String content,
  }) async {
    final bytes = utf8.encode(content);
    final media = drive.Media(
      Stream<List<int>>.fromIterable(<List<int>>[bytes]),
      bytes.length,
    );
    final metadata = drive.File()
      ..name = fileName
      ..mimeType = 'text/plain'
      ..parents = <String>[folderId];

    return _withDriveApi(
      account: account,
      scopes: <String>[drive.DriveApi.driveFileScope],
      action: (api) => api.files.create(metadata, uploadMedia: media),
    );
  }

  Future<String> readTextFile({
    required GoogleSignInAccount account,
    required String fileId,
  }) async {
    final media = await _withDriveApi(
      account: account,
      scopes: <String>[drive.DriveApi.driveFileScope],
      action: (api) => api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ),
    ) as drive.Media;
    return media.stream.transform(utf8.decoder).join();
  }

  Future<List<drive.File>> listFolder({
    required GoogleSignInAccount account,
    required String folderId,
  }) async {
    final result = await _withDriveApi(
      account: account,
      scopes: <String>[drive.DriveApi.driveMetadataReadonlyScope],
      action: (api) => api.files.list(
        q: "'$folderId' in parents and trashed=false",
        $fields: 'files(id,name,mimeType,modifiedTime,size)',
        orderBy: 'folder,name',
        pageSize: 50,
        spaces: 'drive',
      ),
    );
    return result.files ?? <drive.File>[];
  }

  Future<void> deleteFile({
    required GoogleSignInAccount account,
    required String fileId,
  }) async {
    await _withDriveApi(
      account: account,
      scopes: <String>[drive.DriveApi.driveFileScope],
      action: (api) => api.files.delete(fileId),
    );
  }

  Future<String?> findLatestFileId({
    required GoogleSignInAccount account,
    required String folderId,
    required String namePrefix,
  }) async {
    final result = await _withDriveApi(
      account: account,
      scopes: <String>[drive.DriveApi.driveMetadataReadonlyScope],
      action: (api) => api.files.list(
        q:
            "'$folderId' in parents and trashed=false and name contains '$namePrefix'",
        $fields: 'files(id,name,modifiedTime)',
        orderBy: 'modifiedTime desc',
        spaces: 'drive',
        pageSize: 1,
      ),
    );
    return result.files?.isNotEmpty == true ? result.files!.first.id : null;
  }

  Future<drive.File?> findLatestFile({
    required GoogleSignInAccount account,
    required String folderId,
    required String namePrefix,
  }) async {
    final result = await _withDriveApi(
      account: account,
      scopes: <String>[drive.DriveApi.driveMetadataReadonlyScope],
      action: (api) => api.files.list(
        q:
            "'$folderId' in parents and trashed=false and name contains '$namePrefix'",
        $fields: 'files(id,name,modifiedTime)',
        orderBy: 'modifiedTime desc',
        spaces: 'drive',
        pageSize: 1,
      ),
    );
    return result.files?.isNotEmpty == true ? result.files!.first : null;
  }
}

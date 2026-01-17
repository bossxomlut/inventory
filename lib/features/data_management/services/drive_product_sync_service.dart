import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../domain/entities/user/user.dart';
import '../../authentication/provider/auth_provider.dart';
import '../../../services/google_drive_auth_service.dart';
import '../../../services/google_drive_service.dart';
import 'data_export_service.dart';
import 'data_import_service.dart';

class DriveProductExportResult {
  DriveProductExportResult({
    required this.fileId,
    required this.fileName,
    required this.folderId,
    required this.folderName,
  });

  final String fileId;
  final String fileName;
  final String folderId;
  final String folderName;
}

class DriveProductDownload {
  DriveProductDownload({
    required this.fileId,
    required this.fileName,
    required this.content,
  });

  final String fileId;
  final String fileName;
  final String content;
}

class DriveProductFile {
  DriveProductFile({
    required this.id,
    required this.name,
    required this.modifiedTime,
  });

  final String id;
  final String name;
  final DateTime? modifiedTime;
}

class DriveProductListResult {
  DriveProductListResult({
    required this.folderId,
    required this.items,
  });

  final String folderId;
  final List<DriveProductFile> items;
}

class DriveProductSyncService {
  DriveProductSyncService(this._ref)
      : _driveService = GoogleDriveService(),
        _authService = GoogleDriveAuthService();

  static const String folderName = 'InventoryProductExports';
  static const String filePrefix = 'products_export';

  final Ref _ref;
  final GoogleDriveService _driveService;
  final GoogleDriveAuthService _authService;

  Future<DriveProductExportResult> exportProductsToDrive({
    GoogleSignInAccount? account,
  }) async {
    final user = _requireAdmin();
    final signedIn = await _resolveAccount(account);
    final exportService = _ref.read(dataExportServiceProvider);
    final content = await exportService.exportProductsJsonlContent();
    final folderId = await _driveService.ensureFolderId(
      account: signedIn,
      folderName: folderName,
    );
    final fileName = _buildFileName(user);
    final file = await _driveService.writeTextFile(
      account: signedIn,
      folderId: folderId,
      fileName: fileName,
      content: content,
    );
    final fileId = file.id;
    if (fileId == null || fileId.isEmpty) {
      throw StateError('Drive file id missing after upload.');
    }
    return DriveProductExportResult(
      fileId: fileId,
      fileName: fileName,
      folderId: folderId,
      folderName: folderName,
    );
  }

  Future<DriveProductDownload> downloadLatestProductsExport({
    GoogleSignInAccount? account,
  }) async {
    _requireAdmin();
    final signedIn = await _resolveAccount(account);
    final folderId = await _driveService.ensureFolderId(
      account: signedIn,
      folderName: folderName,
    );
    final latestFile = await _driveService.findLatestFile(
      account: signedIn,
      folderId: folderId,
      namePrefix: filePrefix,
    );
    if (latestFile == null || latestFile.id == null) {
      throw StateError('No product export file found in Drive.');
    }

    final content = await _driveService.readTextFile(
      account: signedIn,
      fileId: latestFile.id!,
    );
    return DriveProductDownload(
      fileId: latestFile.id!,
      fileName: latestFile.name ?? 'unknown',
      content: content,
    );
  }

  Future<DriveProductDownload> downloadProductsFile({
    required String fileId,
    required String fileName,
    GoogleSignInAccount? account,
  }) async {
    _requireAdmin();
    final signedIn = await _resolveAccount(account);
    final content = await _driveService.readTextFile(
      account: signedIn,
      fileId: fileId,
    );
    return DriveProductDownload(
      fileId: fileId,
      fileName: fileName,
      content: content,
    );
  }

  Future<DriveProductListResult> listProductFiles({
    GoogleSignInAccount? account,
  }) async {
    _requireAdmin();
    final signedIn = await _resolveAccount(account);
    final folderId = await _driveService.ensureFolderId(
      account: signedIn,
      folderName: folderName,
    );
    final files = await _driveService.listFolder(
      account: signedIn,
      folderId: folderId,
    );
    final items = files
        .where(
          (file) =>
              file.id != null &&
              file.mimeType != 'application/vnd.google-apps.folder',
        )
        .map(
          (file) => DriveProductFile(
            id: file.id!,
            name: file.name ?? 'Unnamed',
            modifiedTime: file.modifiedTime,
          ),
        )
        .toList(growable: false);
    return DriveProductListResult(folderId: folderId, items: items);
  }

  Future<void> deleteProductFile({
    required String fileId,
    GoogleSignInAccount? account,
  }) async {
    _requireAdmin();
    final signedIn = await _resolveAccount(account);
    await _driveService.deleteFile(
      account: signedIn,
      fileId: fileId,
    );
  }

  Future<DataImportResult> importProductsFromDrive(String content) async {
    _requireAdmin();
    final dataImportService = _ref.read(dataImportServiceProvider);
    return dataImportService.importFromJsonlString(content);
  }

  User _requireAdmin() {
    final authState = _ref.read(authControllerProvider);
    final user = authState.maybeWhen(
      authenticated: (user, _) => user,
      orElse: () => null,
    );
    if (user == null || user.role != UserRole.admin) {
      throw StateError('Admin only.');
    }
    return user;
  }

  Future<GoogleSignInAccount> _resolveAccount(
    GoogleSignInAccount? account,
  ) async {
    if (account != null) {
      return account;
    }
    return _authService.ensureSignedIn();
  }

  String _buildFileName(User user) {
    final now = DateTime.now();
    final stamp =
        '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_'
        '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
    return '${filePrefix}_${user.id}_$stamp.jsonl';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

final driveProductSyncServiceProvider =
    Provider<DriveProductSyncService>((ref) {
  return DriveProductSyncService(ref);
});

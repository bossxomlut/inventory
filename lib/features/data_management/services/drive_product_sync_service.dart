import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../domain/entities/user/user.dart';
import '../../../domain/entities/product/inventory.dart';
import '../../../domain/entities/image.dart';
import '../../authentication/provider/auth_provider.dart';
import '../../../services/google_drive_auth_service.dart';
import '../../../services/google_drive_service.dart';
import '../../../services/google_sheets_service.dart';
import 'data_export_service.dart';
import 'data_import_service.dart';
import 'drive_sync_types.dart';

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
    required this.values,
  });

  final String fileId;
  final String fileName;
  final List<List<Object?>> values;
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
        _authService = GoogleDriveAuthService(),
        _sheetsService = GoogleSheetsService();

  static const String folderName = 'InventoryProductExports';
  static const String imageFolderName = 'InventoryProductImages';
  static const String sheetName = 'Products';
  static const String filePrefix = 'products_export';

  final Ref _ref;
  final GoogleDriveService _driveService;
  final GoogleDriveAuthService _authService;
  final GoogleSheetsService _sheetsService;
  String? _imageFolderId;
  final Map<String, String> _imageFormulaCache = <String, String>{};

  Future<DriveProductExportResult> exportProductsToDrive({
    GoogleSignInAccount? account,
    DriveSyncCancellationToken? cancellation,
    DriveSyncProgressCallback? onProgress,
  }) async {
    final user = _requireAdmin();
    final signedIn = await _resolveAccount(account);
    cancellation?.throwIfCancelled();
    final exportService = _ref.read(dataExportServiceProvider);
    onProgress?.call('Đang tổng hợp dữ liệu sản phẩm...');
    final values = await exportService.buildProductsSheetValues(
      imageResolver: (product, maxImageCount) async {
        return _buildImageFormulas(
          product,
          maxImageCount,
          signedIn,
          cancellation: cancellation,
          onProgress: onProgress,
        );
      },
      cancellation: cancellation,
      onProgress: onProgress,
    );
    cancellation?.throwIfCancelled();
    final header = values.isNotEmpty ? values.first : <Object?>[];
    final imageColumnIndex = _findImageColumnStart(header);
    final imageColumnCount = _countImageColumns(header, imageColumnIndex);
    onProgress?.call('Đang tạo thư mục lưu trữ trên Drive...');
    final folderId = await _driveService.ensureFolderId(
      account: signedIn,
      folderName: folderName,
    );
    cancellation?.throwIfCancelled();
    final fileName = _buildFileName(user);
    onProgress?.call('Đang tạo file Google Sheets...');
    final file = await _driveService.createSpreadsheetFile(
      account: signedIn,
      folderId: folderId,
      fileName: fileName,
    );
    final fileId = file.id;
    if (fileId == null || fileId.isEmpty) {
      throw StateError('Drive file id missing after upload.');
    }
    cancellation?.throwIfCancelled();
    onProgress?.call('Đang cấp quyền truy cập ảnh...');
    await _sheetsService.allowExternalUrlAccess(
      account: signedIn,
      spreadsheetId: fileId,
    );
    cancellation?.throwIfCancelled();
    onProgress?.call('Đang ghi dữ liệu vào Sheets...');
    final sheetId = await _sheetsService.writeValues(
      account: signedIn,
      spreadsheetId: fileId,
      sheetTitle: sheetName,
      values: values,
    );
    final List<ColumnWidthConfig> columnWidths = _buildColumnWidths(header, imageColumnIndex);
    if (columnWidths.isNotEmpty) {
      onProgress?.call('Đang định dạng độ rộng cột...');
      await _sheetsService.formatColumnWidths(
        account: signedIn,
        spreadsheetId: fileId,
        sheetId: sheetId,
        columns: columnWidths,
      );
    }
    if (imageColumnIndex >= 0 && imageColumnCount > 0) {
      onProgress?.call('Đang định dạng cột ảnh...');
      await _sheetsService.formatImageColumn(
        account: signedIn,
        spreadsheetId: fileId,
        sheetId: sheetId,
        imageColumnIndex: imageColumnIndex,
        imageColumnCount: imageColumnCount,
        rowCount: values.length,
        rowHeight: 90,
        columnWidth: 100,
      );
    }
    return DriveProductExportResult(
      fileId: fileId,
      fileName: fileName,
      folderId: folderId,
      folderName: folderName,
    );
  }

  List<ColumnWidthConfig> _buildColumnWidths(
    List<Object?> header,
    int imageColumnIndex,
  ) {
    if (header.isEmpty) {
      return <ColumnWidthConfig>[];
    }
    final int totalColumns = header.length;
    final int fixedColumnsEnd = imageColumnIndex >= 0 ? imageColumnIndex : totalColumns;
    const List<int> widths = <int>[
      60, // ID
      220, // Tên sản phẩm
      90, // Số lượng
      140, // Mã vạch
      160, // Danh mục
      120, // Đơn vị
      260, // Mô tả
      100, // Giá
      120, // Theo dõi hạn
      280, // Lô hàng (HSD)
    ];
    final List<ColumnWidthConfig> configs = <ColumnWidthConfig>[];
    for (int i = 0; i < widths.length; i++) {
      if (i >= fixedColumnsEnd || i >= totalColumns) {
        break;
      }
      configs.add(
        ColumnWidthConfig(
          startIndex: i,
          endIndex: i + 1,
          pixelSize: widths[i],
        ),
      );
    }
    return configs;
  }

  Future<List<Object?>> _buildImageFormulas(
    Product product,
    int maxImageCount,
    GoogleSignInAccount account, {
    DriveSyncCancellationToken? cancellation,
    DriveSyncProgressCallback? onProgress,
  }) async {
    if (maxImageCount <= 0) {
      return <Object?>[];
    }
    final paths = _imagePaths(product.images);
    if (paths.isEmpty) {
      return List<Object?>.filled(maxImageCount, '');
    }
    final formulas = <Object?>[];
    for (int i = 0; i < paths.length; i++) {
      cancellation?.throwIfCancelled();
      onProgress?.call('Đang tải ảnh ${i + 1}/${paths.length}...');
      final formula = await _uploadImageFormula(
        product,
        paths[i],
        i,
        account,
        cancellation: cancellation,
      );
      formulas.add(formula);
    }
    if (formulas.length > maxImageCount) {
      return formulas.take(maxImageCount).toList();
    }
    if (formulas.length < maxImageCount) {
      formulas.addAll(
        List<Object?>.filled(maxImageCount - formulas.length, ''),
      );
    }
    return formulas;
  }

  Future<String> _uploadImageFormula(
    Product product,
    String imagePath,
    int imageIndex,
    GoogleSignInAccount account, {
    DriveSyncCancellationToken? cancellation,
  }) async {
    // Yield at start to allow UI updates
    await Future<void>.delayed(Duration.zero);

    final cached = _imageFormulaCache[imagePath];
    if (cached != null) {
      return cached;
    }

    cancellation?.throwIfCancelled();
    final file = File(imagePath);
    if (!await file.exists()) {
      return '';
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return '';
    }

    // Yield after reading file
    await Future<void>.delayed(Duration.zero);

    cancellation?.throwIfCancelled();
    _imageFolderId ??= await _driveService.ensureFolderId(
      account: account,
      folderName: imageFolderName,
    );
    final extension = _fileExtension(imagePath);
    final fileName = 'product_image_${product.id}_${imageIndex}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final uploaded = await _driveService.writeBytesFile(
      account: account,
      folderId: _imageFolderId!,
      fileName: fileName,
      bytes: bytes,
      mimeType: _imageMimeType(extension),
    );

    // Yield after upload
    await Future<void>.delayed(Duration.zero);

    final uploadedId = uploaded.id;
    if (uploadedId == null || uploadedId.isEmpty) {
      throw StateError('Drive image id missing after upload.');
    }
    cancellation?.throwIfCancelled();
    await _driveService.makeFilePublic(
      account: account,
      fileId: uploadedId,
    );
    final url = _driveService.buildPublicFileUrl(uploadedId);
    final formula = '=IMAGE("$url";4;80;80)';
    _imageFormulaCache[imagePath] = formula;
    return formula;
  }

  List<String> _imagePaths(List<ImageStorageModel>? images) {
    if (images == null || images.isEmpty) {
      return <String>[];
    }
    final paths = <String>[];
    for (final image in images) {
      final path = image.path;
      if (path != null && path.trim().isNotEmpty) {
        paths.add(path.trim());
      }
    }
    return paths;
  }

  int _findImageColumnStart(List<Object?> header) {
    for (int i = 0; i < header.length; i++) {
      final label = header[i];
      if (label is String && _isImageHeaderLabel(label)) {
        return i;
      }
    }
    return -1;
  }

  int _countImageColumns(List<Object?> header, int startIndex) {
    if (startIndex < 0) {
      return 0;
    }
    int count = 0;
    for (int i = startIndex; i < header.length; i++) {
      final label = header[i];
      if (label is String && _isImageHeaderLabel(label)) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  bool _isImageHeaderLabel(String label) {
    final normalized = label.trim().toLowerCase();
    return normalized.startsWith('ảnh') || normalized.startsWith('image');
  }

  String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '';
    }
    return path.substring(dotIndex).toLowerCase();
  }

  String _imageMimeType(String extension) {
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      default:
        return 'image/jpeg';
    }
  }

  Future<DriveProductDownload> downloadLatestProductsExport({
    GoogleSignInAccount? account,
    DriveSyncCancellationToken? cancellation,
    DriveSyncProgressCallback? onProgress,
  }) async {
    _requireAdmin();
    final signedIn = await _resolveAccount(account);
    cancellation?.throwIfCancelled();
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

    return downloadProductsFile(
      fileId: latestFile.id!,
      fileName: latestFile.name ?? 'unknown',
      account: signedIn,
      cancellation: cancellation,
      onProgress: onProgress,
    );
  }

  Future<DriveProductDownload> downloadProductsFile({
    required String fileId,
    required String fileName,
    GoogleSignInAccount? account,
    DriveSyncCancellationToken? cancellation,
    DriveSyncProgressCallback? onProgress,
  }) async {
    _requireAdmin();
    final signedIn = await _resolveAccount(account);
    cancellation?.throwIfCancelled();
    onProgress?.call('Đang tải dữ liệu từ Google Sheets...');
    final values = await _sheetsService.readValues(
      account: signedIn,
      spreadsheetId: fileId,
      sheetTitle: sheetName,
      valueRenderOption: 'FORMULA',
    );
    cancellation?.throwIfCancelled();
    return DriveProductDownload(
      fileId: fileId,
      fileName: fileName,
      values: values,
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
          (file) => file.id != null && file.mimeType == 'application/vnd.google-apps.spreadsheet' && (file.name ?? '').contains(filePrefix),
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

  Future<DataImportResult> importProductsFromSheetValues(
    List<List<Object?>> values, {
    DriveSyncCancellationToken? cancellation,
    DriveSyncProgressCallback? onProgress,
  }) async {
    _requireAdmin();
    final dataImportService = _ref.read(dataImportServiceProvider);
    return dataImportService.importFromSheetValues(
      values,
      cancellation: cancellation,
      onProgress: onProgress,
    );
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
    final stamp = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_'
        '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
    return '${filePrefix}_${user.id}_$stamp';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

final driveProductSyncServiceProvider = Provider<DriveProductSyncService>((ref) {
  return DriveProductSyncService(ref);
});

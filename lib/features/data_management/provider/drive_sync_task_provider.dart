import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/data_import_service.dart';
import '../services/drive_product_sync_service.dart';
import '../services/drive_sync_types.dart';

enum DriveSyncTaskType { export, import }

enum DriveSyncTaskStatus { idle, running, success, error, cancelled }

@immutable
class DriveSyncTaskState {
  const DriveSyncTaskState({
    required this.status,
    this.type,
    this.message,
    this.fileName,
    this.importResult,
  });

  const DriveSyncTaskState.idle()
      : status = DriveSyncTaskStatus.idle,
        type = null,
        message = null,
        fileName = null,
        importResult = null;

  final DriveSyncTaskStatus status;
  final DriveSyncTaskType? type;
  final String? message;
  final String? fileName;
  final DataImportResult? importResult;

  bool get isRunning => status == DriveSyncTaskStatus.running;

  bool get isVisible => status != DriveSyncTaskStatus.idle;

  DriveSyncTaskState copyWith({
    DriveSyncTaskStatus? status,
    DriveSyncTaskType? type,
    String? message,
    String? fileName,
    DataImportResult? importResult,
  }) {
    return DriveSyncTaskState(
      status: status ?? this.status,
      type: type ?? this.type,
      message: message ?? this.message,
      fileName: fileName ?? this.fileName,
      importResult: importResult ?? this.importResult,
    );
  }
}

final driveSyncTaskProvider =
    StateNotifierProvider<DriveSyncTaskNotifier, DriveSyncTaskState>((ref) {
  return DriveSyncTaskNotifier(ref);
});

class DriveSyncTaskNotifier extends StateNotifier<DriveSyncTaskState> {
  DriveSyncTaskNotifier(this._ref) : super(const DriveSyncTaskState.idle());

  final Ref _ref;
  DriveSyncCancellationToken? _cancellation;
  Timer? _dismissTimer;

  Future<void> startExport({GoogleSignInAccount? account}) async {
    if (state.isRunning) {
      return;
    }
    _dismissTimer?.cancel();
    final DriveSyncCancellationToken cancellation =
        DriveSyncCancellationToken();
    _cancellation = cancellation;
    state = const DriveSyncTaskState(
      status: DriveSyncTaskStatus.running,
      type: DriveSyncTaskType.export,
      message: 'Đang chuẩn bị dữ liệu...',
    );
    await Future<void>.delayed(Duration.zero);
    try {
      final driveService = _ref.read(driveProductSyncServiceProvider);
      final result = await driveService.exportProductsToDrive(
        account: account,
        cancellation: cancellation,
        onProgress: _updateProgress,
      );
      if (cancellation.isCancelled) {
        state = const DriveSyncTaskState(
          status: DriveSyncTaskStatus.cancelled,
          type: DriveSyncTaskType.export,
          message: 'Đã hủy xuất dữ liệu.',
        );
        return;
      }
      state = DriveSyncTaskState(
        status: DriveSyncTaskStatus.success,
        type: DriveSyncTaskType.export,
        message: 'Đã xuất lên Sheets: ${result.fileName}',
        fileName: result.fileName,
      );
      _scheduleDismiss();
    } on DriveSyncCancelledException {
      state = const DriveSyncTaskState(
        status: DriveSyncTaskStatus.cancelled,
        type: DriveSyncTaskType.export,
        message: 'Đã hủy xuất dữ liệu.',
      );
      _scheduleDismiss();
    } catch (e) {
      state = DriveSyncTaskState(
        status: DriveSyncTaskStatus.error,
        type: DriveSyncTaskType.export,
        message: 'Lỗi xuất Sheets: $e',
      );
      _scheduleDismiss();
    } finally {
      _cancellation = null;
    }
  }

  Future<void> startImport({
    required DriveProductFile file,
    GoogleSignInAccount? account,
  }) async {
    if (state.isRunning) {
      return;
    }
    _dismissTimer?.cancel();
    final DriveSyncCancellationToken cancellation =
        DriveSyncCancellationToken();
    _cancellation = cancellation;
    state = DriveSyncTaskState(
      status: DriveSyncTaskStatus.running,
      type: DriveSyncTaskType.import,
      message: 'Đang tải file ${file.name}...',
      fileName: file.name,
    );
    await Future<void>.delayed(Duration.zero);
    try {
      final driveService = _ref.read(driveProductSyncServiceProvider);
      final download = await driveService.downloadProductsFile(
        fileId: file.id,
        fileName: file.name,
        account: account,
        cancellation: cancellation,
        onProgress: _updateProgress,
      );
      if (download.values.isEmpty) {
        throw StateError('Sheet trống hoặc không đọc được dữ liệu.');
      }
      cancellation.throwIfCancelled();
      _updateProgress('Đang nhập dữ liệu...');
      final result = await driveService.importProductsFromSheetValues(
        download.values,
        cancellation: cancellation,
        onProgress: _updateProgress,
      );
      if (cancellation.isCancelled) {
        state = const DriveSyncTaskState(
          status: DriveSyncTaskStatus.cancelled,
          type: DriveSyncTaskType.import,
          message: 'Đã hủy nhập dữ liệu.',
        );
        return;
      }
      final bool hasErrors = result.hasErrors;
      state = DriveSyncTaskState(
        status:
            hasErrors ? DriveSyncTaskStatus.error : DriveSyncTaskStatus.success,
        type: DriveSyncTaskType.import,
        message: _buildImportMessage(result, file.name),
        fileName: file.name,
        importResult: result,
      );
      _scheduleDismiss();
    } on DriveSyncCancelledException {
      state = const DriveSyncTaskState(
        status: DriveSyncTaskStatus.cancelled,
        type: DriveSyncTaskType.import,
        message: 'Đã hủy nhập dữ liệu.',
      );
      _scheduleDismiss();
    } catch (e) {
      state = DriveSyncTaskState(
        status: DriveSyncTaskStatus.error,
        type: DriveSyncTaskType.import,
        message: 'Lỗi nhập Drive: $e',
        fileName: file.name,
      );
      _scheduleDismiss();
    } finally {
      _cancellation = null;
    }
  }

  void cancel() {
    if (!state.isRunning) {
      return;
    }
    _cancellation?.cancel();
    state = state.copyWith(message: 'Đang hủy xử lý...');
  }

  void dismiss() {
    if (state.isRunning) {
      return;
    }
    _dismissTimer?.cancel();
    state = const DriveSyncTaskState.idle();
  }

  void _scheduleDismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      if (!state.isRunning) {
        state = const DriveSyncTaskState.idle();
      }
    });
  }

  void _updateProgress(String message) {
    if (!state.isRunning) {
      return;
    }
    state = state.copyWith(message: message);
  }

  String _buildImportMessage(DataImportResult result, String fileName) {
    if (!result.hasErrors) {
      return 'Đã nhập dữ liệu từ: $fileName';
    }
    if (result.successfulImports > 0) {
      return 'Nhập xong ${result.successfulImports}/${result.totalLines} dòng từ $fileName';
    }
    return 'Không thể nhập dữ liệu từ: $fileName';
  }
}

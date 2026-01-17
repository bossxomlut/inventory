import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/user/user.dart';
import '../../provider/theme.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import '../../services/google_drive_auth_service.dart';
import '../authentication/provider/auth_provider.dart';
import 'services/data_import_service.dart';
import 'services/drive_product_sync_service.dart';

@RoutePage()
class DriveProductSyncPage extends ConsumerStatefulWidget {
  const DriveProductSyncPage({super.key});

  @override
  ConsumerState<DriveProductSyncPage> createState() =>
      _DriveProductSyncPageState();
}

class _DriveProductSyncPageState extends ConsumerState<DriveProductSyncPage> {
  bool _busy = false;
  bool _loadingFiles = false;
  String? _status;
  String? _lastFileName;
  GoogleSignInAccount? _account;
  List<DriveProductFile> _files = <DriveProductFile>[];
  final GoogleDriveAuthService _authService = GoogleDriveAuthService();

  @override
  void initState() {
    super.initState();
    final cachedAccount = _authService.currentAccount;
    if (cachedAccount != null) {
      _account = cachedAccount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFiles();
      });
    } else {
      _restoreAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final authState = ref.watch(authControllerProvider);
    final bool isAdmin = authState.maybeWhen(
      authenticated: (user, _) => user.role == UserRole.admin,
      orElse: () => false,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Google Drive - Product Sync',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isAdmin ? _buildAdminBody(context, theme) : _buildAccessDenied(context),
      ),
    );
  }

  Widget _buildAdminBody(BuildContext context, AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quy tắc lưu trữ',
                  style: theme.headingSemibold20Default,
                ),
                const SizedBox(height: 8),
                Text(
                  'Folder: ${DriveProductSyncService.folderName}',
                  style: theme.textRegular14Default,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sheet: ${DriveProductSyncService.sheetName}',
                  style: theme.textRegular14Default,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tên file: ${DriveProductSyncService.filePrefix}_<adminId>_yyyyMMdd_HHmmss',
                  style: theme.textRegular14Default,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_account == null) ...[
          Text(
            'Chưa đăng nhập Google.',
            style: theme.textRegular14Default,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _busy ? null : _signIn,
            icon: const Icon(Icons.login),
            label: const Text('Sign in with Google'),
          ),
        ] else ...[
          _buildAccountCard(context, theme),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _exportToDrive,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Export to Sheets'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _refreshFiles,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh files'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFileList(context, theme),
        ],
        if (_busy && _account == null) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        if (_status != null) ...[
          const SizedBox(height: 16),
          Text(
            _status!,
            style: theme.textRegular14Default,
          ),
        ],
        if (_lastFileName != null) ...[
          const SizedBox(height: 8),
          Text(
            'Last file: $_lastFileName',
            style: theme.textRegular12Sublest,
          ),
        ],
      ],
    );
  }

  Widget _buildAccountCard(BuildContext context, AppThemeData theme) {
    final account = _account!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  account.photoUrl != null ? NetworkImage(account.photoUrl!) : null,
              child: account.photoUrl == null
                  ? const Icon(Icons.person_outline)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName ?? 'Unknown',
                    style: theme.textMedium14Default,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.email,
                    style: theme.textRegular12Sublest,
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: _busy ? null : _logoutGoogle,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(BuildContext context, AppThemeData theme) {
    if (_loadingFiles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_files.isEmpty) {
      return Text(
        'Không có file trong folder.',
        style: theme.textRegular14Default,
      );
    }
    return Expanded(
      child: ListView.separated(
        itemCount: _files.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final file = _files[index];
          final modified = file.modifiedTime;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(file.name),
              subtitle: modified != null
                  ? Text('Modified: ${modified.toLocal()}')
                  : const Text('Modified: -'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: _busy ? null : () => _importFile(file),
                    icon: const Icon(Icons.cloud_download_outlined),
                    tooltip: 'Import',
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => _deleteFile(file),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, color: theme.colorError, size: 48),
          const SizedBox(height: 12),
          Text(
            'Chỉ admin mới được phép sử dụng tính năng này.',
            style: theme.textRegular14Default,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _restoreAccount() async {
    setState(() {
      _busy = true;
    });
    try {
      final restored = await _authService.tryRestore();
      if (!mounted) return;
      if (restored != null) {
        setState(() {
          _account = restored;
        });
        await _loadFiles();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Không thể khôi phục đăng nhập: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final account = await _authService.signIn();
      if (!mounted) return;
      setState(() {
        _account = account;
        _status = 'Đăng nhập thành công';
      });
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Đăng nhập thất bại: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _logoutGoogle() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await _authService.signOut();
      if (!mounted) return;
      setState(() {
        _account = null;
        _files = <DriveProductFile>[];
        _status = 'Đã đăng xuất Google';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Không thể đăng xuất: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportToDrive() async {
    if (_account == null) {
      await _signIn();
      if (_account == null) {
        return;
      }
    }
    final shouldProceed = await _confirm(
      title: 'Xuất sản phẩm lên Google Sheets',
      message: 'Bạn có chắc chắn muốn xuất dữ liệu sản phẩm lên Google Sheets?',
    );
    if (!shouldProceed) {
      return;
    }

    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final driveService = ref.read(driveProductSyncServiceProvider);
      final result = await driveService.exportProductsToDrive(
        account: _account,
      );
      if (!mounted) return;
      setState(() {
        _status = 'Đã xuất sản phẩm lên Sheets: ${result.fileName}';
        _lastFileName = result.fileName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export success: ${result.fileName}')),
      );
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Lỗi xuất Sheets: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xuất Sheets: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _refreshFiles() async {
    if (_account == null) {
      return;
    }
    await _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (_account == null) {
      return;
    }
    setState(() {
      _loadingFiles = true;
    });
    try {
      final driveService = ref.read(driveProductSyncServiceProvider);
      final result = await driveService.listProductFiles(account: _account);
      if (!mounted) return;
      setState(() {
        _files = result.items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Không thể tải danh sách file: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingFiles = false;
      });
    }
  }

  Future<void> _importFile(DriveProductFile file) async {
    final shouldProceed = await _confirm(
      title: 'Nhập sản phẩm từ Google Sheets',
      message: 'Bạn có chắc chắn muốn nhập dữ liệu từ "${file.name}"?',
    );
    if (!shouldProceed) {
      return;
    }

    if (_account == null) {
      await _signIn();
      if (_account == null) {
        return;
      }
    }

    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final driveService = ref.read(driveProductSyncServiceProvider);
      final download = await driveService.downloadProductsFile(
        fileId: file.id,
        fileName: file.name,
        account: _account,
      );
      if (!mounted) return;
      final dataImportService = ref.read(dataImportServiceProvider);
      if (download.values.isEmpty) {
        throw StateError('Sheet trống hoặc không đọc được dữ liệu.');
      }
      final result =
          await dataImportService.importFromSheetValues(download.values);
      if (context.mounted) {
        await DataImportResultDialog.showResult(
          context,
          result,
          title: 'Nhập dữ liệu sản phẩm từ Google Sheets',
        );
      }
      setState(() {
        _status = 'Đã nhập dữ liệu từ: ${file.name}';
        _lastFileName = file.name;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Lỗi nhập Drive: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _deleteFile(DriveProductFile file) async {
    final shouldProceed = await _confirm(
      title: 'Xóa file trên Drive',
      message: 'Bạn có chắc chắn muốn xóa "${file.name}"?',
    );
    if (!shouldProceed) {
      return;
    }

    if (_account == null) {
      await _signIn();
      if (_account == null) {
        return;
      }
    }

    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final driveService = ref.read(driveProductSyncServiceProvider);
      await driveService.deleteProductFile(
        fileId: file.id,
        account: _account,
      );
      if (!mounted) return;
      setState(() {
        _status = 'Đã xóa file: ${file.name}';
      });
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Lỗi xóa file: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

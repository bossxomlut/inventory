import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../../domain/entities/user/user.dart';
import '../../provider/theme.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import '../../services/google_drive_auth_service.dart';
import '../authentication/provider/auth_provider.dart';
import 'services/drive_product_sync_service.dart';
import 'provider/drive_sync_task_provider.dart';

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
  GoogleSignInAccount? _account;
  List<DriveProductFile> _files = <DriveProductFile>[];
  final GoogleDriveAuthService _authService = GoogleDriveAuthService();
  ProviderSubscription<DriveSyncTaskState>? _syncListener;

  @override
  void initState() {
    super.initState();
    _syncListener = ref.listenManual<DriveSyncTaskState>(
      driveSyncTaskProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }
        if (next.status == DriveSyncTaskStatus.success) {
          if (next.type == DriveSyncTaskType.export && next.fileName != null) {
            showSuccess(
              context: context,
              message: 'Đã xuất sản phẩm lên Drive thành công!',
            );
            _loadFilesSilently();
          }
        }
        final bool shouldShowImportResult =
            next.type == DriveSyncTaskType.import &&
                next.importResult != null &&
                (next.status == DriveSyncTaskStatus.success ||
                    next.status == DriveSyncTaskStatus.error);
        if (shouldShowImportResult) {
          DataImportResultDialog.showResult(
            context,
            next.importResult!,
            title: 'Nhập dữ liệu sản phẩm từ Google Sheets',
          );
        }
        if (next.status == DriveSyncTaskStatus.error) {
          final errorMsg = next.message ?? 'Có lỗi khi xử lý dữ liệu.';
          showError(context: context, message: errorMsg);
        }
        if (next.status == DriveSyncTaskStatus.cancelled) {
          showInfo(context: context, message: 'Đã hủy thao tác');
        }
      },
    );
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
  void dispose() {
    _syncListener?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final authState = ref.watch(authControllerProvider);
    final syncState = ref.watch(driveSyncTaskProvider);
    final bool isAdmin = authState.maybeWhen(
      authenticated: (user, _) => user.role == UserRole.admin,
      orElse: () => false,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Đồng bộ Google Drive',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isAdmin
            ? _buildAdminBody(context, theme, syncState)
            : _buildAccessDenied(context),
      ),
    );
  }

  Widget _buildAdminBody(
    BuildContext context,
    AppThemeData theme,
    DriveSyncTaskState syncState,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorPrimary.withOpacity(0.1),
                  theme.colorSecondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorBorderSublest,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: theme.colorPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quy tắc lưu trữ',
                      style: theme.headingSemibold20Default,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  theme,
                  Icons.folder_outlined,
                  'Folder file',
                  DriveProductSyncService.folderName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.photo_library_outlined,
                  'Folder ảnh',
                  DriveProductSyncService.imageFolderName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.table_chart_outlined,
                  'Sheet',
                  DriveProductSyncService.sheetName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.description_outlined,
                  'Tên file',
                  '${DriveProductSyncService.filePrefix}_<adminId>_yyyyMMdd_HHmmss',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Sync Status
          _buildSyncStatus(theme, syncState),
          if (syncState.status == DriveSyncTaskStatus.running)
            const SizedBox(height: 20),
          
          // Account Section
          if (_account == null) ...[
            _buildSignInSection(context, theme),
          ] else ...[
            _buildAccountCard(context, theme),
            const SizedBox(height: 20),
            _buildActionButtons(theme),
            const SizedBox(height: 20),
            _buildFileList(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    AppThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorIconSubtle),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textRegular14Default,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: theme.textMedium14Default,
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInSection(BuildContext context, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorBackgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorBorderSublest),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_outlined,
              size: 48,
              color: theme.colorPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kết nối Google Drive',
            style: theme.headingSemibold20Default,
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng nhập để đồng bộ dữ liệu sản phẩm với Google Sheets',
            style: theme.textRegular14Subtle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _signIn,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: Text(_busy ? 'Đang kết nối...' : 'Đăng nhập với Google'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _exportToDrive,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Xuất lên Drive'),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _loadingFiles ? null : _refreshFiles,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _loadingFiles 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildSyncStatus(AppThemeData theme, DriveSyncTaskState syncState) {
    if (syncState.status != DriveSyncTaskStatus.running) {
      return const SizedBox.shrink();
    }
    final String message = (syncState.message ?? '').trim().isEmpty
        ? 'Đang xử lý dữ liệu...'
        : syncState.message!;
    
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorPrimary.withOpacity(0.1),
              theme.colorSecondary.withOpacity(0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorPrimary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorPrimary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: theme.textMedium14Default,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: theme.colorTextSubtle,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Bạn có thể rời màn hình, tiến trình vẫn tiếp tục',
                              style: theme.textRegular12Subtle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(driveSyncTaskProvider.notifier).cancel(),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Hủy'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorError,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AppThemeData theme,
  ) {
    final account = _account!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorBackgroundSurface,
            theme.colorPrimary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorBorderSublest,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorPrimary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage:
                  account.photoUrl != null ? NetworkImage(account.photoUrl!) : null,
              child: account.photoUrl == null
                  ? Icon(
                      Icons.person_outline,
                      size: 28,
                      color: theme.colorIconSubtle,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colorTextSupportGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Đã kết nối',
                      style: theme.textRegular12Subtle.copyWith(
                        color: theme.colorTextSupportGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  account.displayName ?? 'Unknown',
                  style: theme.textMedium14Default,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  account.email,
                  style: theme.textRegular12Sublest,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _logoutGoogle,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(
    BuildContext context,
    AppThemeData theme,
  ) {
    if (_loadingFiles) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tải danh sách file...',
              style: theme.textRegular14Subtle,
            ),
          ],
        ),
      );
    }
    
    if (_files.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorBackgroundSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorBorderSublest),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: theme.colorIconSubtle,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có file nào',
              style: theme.textMedium16Default,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy xuất dữ liệu lên Drive để bắt đầu',
              style: theme.textRegular14Subtle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: theme.colorIconSubtle,
              ),
              const SizedBox(width: 8),
              Text(
                'Danh sách file (${_files.length})',
                style: theme.textMedium16Default,
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _files.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final file = _files[index];
            final modified = file.modifiedTime;
            
            return Container(
              decoration: BoxDecoration(
                color: theme.colorBackgroundSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorBorderSublest,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.table_chart,
                    color: theme.colorPrimary,
                    size: 24,
                  ),
                ),
                title: Text(
                  file.name,
                  style: theme.textMedium14Default,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: modified != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: theme.colorIconSubtle,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(modified),
                              style: theme.textRegular12Subtle,
                            ),
                          ],
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _importFile(file),
                      icon: Icon(
                        Icons.download_outlined,
                        color: theme.colorTextSupportBlue,
                      ),
                      tooltip: 'Nhập dữ liệu',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorTextSupportBlue.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _busy ? null : () => _deleteFile(file),
                      icon: Icon(
                        Icons.delete_outline,
                        color: _busy
                            ? theme.colorIconDisable
                            : theme.colorError,
                      ),
                      tooltip: 'Xóa file',
                      style: IconButton.styleFrom(
                        backgroundColor: _busy
                            ? theme.colorDisabled
                            : theme.colorError.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildAccessDenied(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorBackgroundSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorBorderSublest),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorError.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                color: theme.colorError,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quyền truy cập bị hạn chế',
              style: theme.headingSemibold20Default,
            ),
            const SizedBox(height: 12),
            Text(
              'Chỉ admin mới được phép sử dụng tính năng này.',
              style: theme.textRegular14Subtle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      showError(context: context, message: 'Không thể khôi phục đăng nhập');
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
    });
    try {
      final account = await _authService.signIn();
      if (!mounted) return;
      setState(() {
        _account = account;
      });
      showSuccess(context: context, message: 'Đăng nhập thành công!');
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      showError(context: context, message: 'Đăng nhập thất bại');
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
    });
    try {
      await _authService.signOut();
      if (!mounted) return;
      setState(() {
        _account = null;
        _files = <DriveProductFile>[];
      });
      showSuccess(context: context, message: 'Đã đăng xuất thành công');
    } catch (e) {
      if (!mounted) return;
      showError(context: context, message: 'Không thể đăng xuất');
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  void _exportToDrive() {
    if (_account == null) {
      showInfo(
        context: context,
        message: 'Vui lòng đăng nhập trước',
      );
      return;
    }
    
    // Check if already processing
    final syncState = ref.read(driveSyncTaskProvider);
    if (syncState.status == DriveSyncTaskStatus.running) {
      showInfo(
        context: context,
        message: 'Đang có tiến trình đang chạy. Vui lòng đợi hoặc hủy trước.',
      );
      return;
    }

    ref.read(driveSyncTaskProvider.notifier).startExport(account: _account);
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
      
      // Sort files by modified time (newest first)
      final sortedFiles = List<DriveProductFile>.from(result.items)
        ..sort((a, b) {
          if (a.modifiedTime == null && b.modifiedTime == null) return 0;
          if (a.modifiedTime == null) return 1;
          if (b.modifiedTime == null) return -1;
          return b.modifiedTime!.compareTo(a.modifiedTime!);
        });
      
      setState(() {
        _files = sortedFiles;
      });
    } catch (e) {
      if (!mounted) return;
      showError(context: context, message: 'Không thể tải danh sách file');
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingFiles = false;
      });
    }
  }

  Future<void> _loadFilesSilently() async {
    if (_account == null) {
      return;
    }
    try {
      final driveService = ref.read(driveProductSyncServiceProvider);
      final result = await driveService.listProductFiles(account: _account);
      if (!mounted) return;
      
      // Sort files by modified time (newest first)
      final sortedFiles = List<DriveProductFile>.from(result.items)
        ..sort((a, b) {
          if (a.modifiedTime == null && b.modifiedTime == null) return 0;
          if (a.modifiedTime == null) return 1;
          if (b.modifiedTime == null) return -1;
          return b.modifiedTime!.compareTo(a.modifiedTime!);
        });
      
      setState(() {
        _files = sortedFiles;
      });
    } catch (e) {
      // Silently fail, don't show error for background refresh
    }
  }

  void _importFile(DriveProductFile file) {
    if (_account == null) {
      showInfo(
        context: context,
        message: 'Vui lòng đăng nhập trước',
      );
      return;
    }
    
    // Check if already processing
    final syncState = ref.read(driveSyncTaskProvider);
    if (syncState.status == DriveSyncTaskStatus.running) {
      showInfo(
        context: context,
        message: 'Đang có tiến trình đang chạy. Vui lòng đợi hoặc hủy trước.',
      );
      return;
    }

    ref.read(driveSyncTaskProvider.notifier).startImport(
          file: file,
          account: _account,
        );
  }

  Future<void> _deleteFile(DriveProductFile file) async {
    if (_account == null) {
      showInfo(
        context: context,
        message: 'Vui lòng đăng nhập trước',
      );
      return;
    }
    
    final shouldProceed = await _confirm(
      title: 'Xóa file trên Drive',
      message: 'Bạn có chắc chắn muốn xóa "${file.name}"?',
    );
    if (!shouldProceed) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final driveService = ref.read(driveProductSyncServiceProvider);
      await driveService.deleteProductFile(
        fileId: file.id,
        account: _account,
      );
      if (!mounted) return;
      
      // Remove the deleted file from the list instead of reloading
      setState(() {
        _files.removeWhere((f) => f.id == file.id);
      });
      
      showSuccess(context: context, message: 'Đã xóa file thành công');
    } catch (e) {
      if (!mounted) return;
      showError(context: context, message: 'Lỗi xóa file');
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
    final theme = context.appTheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline,
                color: theme.colorPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.headingSemibold20Default,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: theme.textRegular14Default,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

}

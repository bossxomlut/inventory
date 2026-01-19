import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../provider/theme.dart';
import '../../../resources/index.dart';
import '../provider/drive_sync_task_provider.dart';

class DriveSyncTaskBanner extends ConsumerWidget {
  const DriveSyncTaskBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DriveSyncTaskState state = ref.watch(driveSyncTaskProvider);
    if (!state.isVisible) {
      return const SizedBox.shrink();
    }
    final AppThemeData theme = context.appTheme;
    final bool isRunning = state.status == DriveSyncTaskStatus.running;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        top: false,
        child: Material(
          elevation: 6,
          color: theme.colorBackground,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorBorderSubtle),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusIcon(theme, state),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _buildTitle(state),
                        style: theme.textMedium14Default,
                      ),
                      if (state.message != null && state.message!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            state.message!,
                            style: theme.textRegular12Subtle,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isRunning)
                  TextButton(
                    onPressed: () =>
                        ref.read(driveSyncTaskProvider.notifier).cancel(),
                    child: const Text('Hủy'),
                  )
                else
                  IconButton(
                    onPressed: () =>
                        ref.read(driveSyncTaskProvider.notifier).dismiss(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Đóng',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(AppThemeData theme, DriveSyncTaskState state) {
    switch (state.status) {
      case DriveSyncTaskStatus.running:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorPrimary,
          ),
        );
      case DriveSyncTaskStatus.success:
        return Icon(Icons.check_circle, color: theme.colorTextSupportGreen);
      case DriveSyncTaskStatus.error:
        return Icon(Icons.error, color: theme.colorError);
      case DriveSyncTaskStatus.cancelled:
        return Icon(Icons.cancel, color: theme.colorTextSubtle);
      case DriveSyncTaskStatus.idle:
        return const SizedBox(width: 18, height: 18);
    }
  }

  String _buildTitle(DriveSyncTaskState state) {
    switch (state.status) {
      case DriveSyncTaskStatus.running:
        return state.type == DriveSyncTaskType.import
            ? 'Đang nhập dữ liệu từ Drive'
            : 'Đang xuất dữ liệu lên Drive';
      case DriveSyncTaskStatus.success:
        return state.type == DriveSyncTaskType.import
            ? 'Nhập dữ liệu hoàn tất'
            : 'Xuất dữ liệu hoàn tất';
      case DriveSyncTaskStatus.error:
        return state.type == DriveSyncTaskType.import
            ? 'Nhập dữ liệu có lỗi'
            : 'Xuất dữ liệu có lỗi';
      case DriveSyncTaskStatus.cancelled:
        return 'Đã hủy tác vụ';
      case DriveSyncTaskStatus.idle:
        return '';
    }
  }
}

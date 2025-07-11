import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../provider/index.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';

@RoutePage()
class SettingPage extends WidgetByDeviceTemplate {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: LKey.setting.tr(context: context),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Quản lý dữ liệu',
              style: theme.headingSemibold20Default.copyWith(
                color: theme.colorTextSubtle,
                fontSize: 18,
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(HugeIcons.strokeRoundedDatabaseAdd),
                  title: const Text('Tạo từ dữ liệu mẫu'),
                  onTap: () {
                    appRouter.goToCreateSampleData();
                  },
                ),
                const _Divider(),
                ListTile(
                  leading: const Icon(HugeIcons.strokeRoundedDatabaseAdd),
                  title: const Text('Nhập dữ liệu từ file'),
                  onTap: () {},
                ),
                const _Divider(),
                ListTile(
                  leading: const Icon(HugeIcons.strokeRoundedDatabaseExport),
                  title: const Text('Xuất dữ liệu'),
                  onTap: () {
                    appRouter.goToExportData();
                  },
                ),
                const _Divider(),
                ListTile(
                  leading: const Icon(HugeIcons.strokeRoundedDatabaseSetting),
                  title: const Text('Xóa dữ liệu'),
                  onTap: () {
                    appRouter.goToDeleteData();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Về ứng dụng',
              style: theme.headingSemibold20Default.copyWith(
                color: theme.colorTextSubtle,
                fontSize: 18,
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(HugeIcons.strokeRoundedHelpCircle),
                  title: const Text('Hướng dẫn sử dụng'),
                  onTap: () {},
                ),
                const _Divider(),
                ListTile(
                  leading: const Icon(HugeIcons.strokeRoundedStar),
                  title: const Text('Đánh giá ứng dụng'),
                  onTap: () {},
                ),
                const _Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LText(
              LKey.settingAccount,
              style: theme.headingSemibold20Default.copyWith(
                color: theme.colorTextSubtle,
                fontSize: 18,
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(HugeIcons.strokeRoundedResetPassword),
                  title: LText(
                    LKey.settingChangePassword,
                  ),
                  onTap: () {
                    appRouter.goToResetPassword();
                  },
                ),
                const _Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Material(
                    color: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Handle logout action
                        // For example, clear user session, navigate to login page, etc.
                        ref.read(authControllerProvider.notifier).logout();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(HugeIcons.strokeRoundedLogout03),
                            const SizedBox(width: 10),
                            LText(
                              LKey.settingLogout,
                              style: theme.buttonSemibold14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          //logout button
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 54.0),
      child: Divider(
        height: 0.2,
        thickness: 0.4,
        color: theme.colorDivider,
      ),
    );
  }
}

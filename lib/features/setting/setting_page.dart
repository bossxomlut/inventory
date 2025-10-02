import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/ads/ad_banner_widget.dart';
import '../../domain/entities/permission/permission.dart';
import '../../provider/index.dart';
import '../../provider/permissions.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';
import '../onboarding/onboarding_service.dart';
import 'app_review_utils.dart';

@RoutePage()
class SettingPage extends WidgetByDeviceTemplate {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final authState = ref.watch(authControllerProvider);
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);

    final grantedPermissions = permissionsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => <PermissionKey>{},
    );

    final bool canAccessDataManagement = grantedPermissions.intersection({
      PermissionKey.dataCreateSample,
      PermissionKey.dataImport,
      PermissionKey.dataExport,
      PermissionKey.dataDelete,
    }).isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(
        title: LKey.setting.tr(context: context),
      ),
      body: ListView(
        children: [
          const AdBannerSmallWidget(),
          // Only show "Quản lý dữ liệu" section for admin and guest users
          if (canAccessDataManagement) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  // ListTile(
                  //   leading: const Icon(HugeIcons.strokeRoundedDatabaseAdd),
                  //   title: const Text('Nhập dữ liệu từ file'),
                  //   onTap: () {
                  //     appRouter.goToImportData();
                  //   },
                  // ),
                  // const _Divider(),
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
          ],
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Gửi phản hồi'),
                  subtitle: const Text('Báo lỗi hoặc đề xuất tính năng mới'),
                  onTap: () => appRouter.push(const FeedbackRoute()),
                ),
                const _Divider(),
                Builder(builder: (context) {
                  final inAppReviewUtil =
                      InAppReviewUtil(ref.read(simpleStorageProvider));
                  return FutureBuilder<bool>(
                    initialData: false,
                    future: inAppReviewUtil.isAvailable(),
                    builder: (context, snapshot) {
                      // Check if in-app review is available
                      if (!snapshot.hasData || !(snapshot.data ?? false)) {
                        return const SizedBox();
                      }
                      return ListTile(
                        leading: const Icon(HugeIcons.strokeRoundedStar),
                        title: const Text('Đánh giá ứng dụng'),
                        onTap: () async {
                          inAppReviewUtil.openStoreListing();
                        },
                      );
                    },
                  );
                }),
                const _Divider(),
                if (canAccessDataManagement) ...[
                  ListTile(
                    leading: const Icon(HugeIcons.strokeRoundedRefresh),
                    title: const Text('Xem lại hướng dẫn'),
                    subtitle: const Text('Hiển thị lại màn hình giới thiệu'),
                    onTap: () => _resetOnboarding(context, ref),
                  ),
                  const _Divider(),
                ],
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
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
                ),
              ],
            ),
          ),
          //logout button
          FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                return Align(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Phiên bản: ${snapshot.data?.version ?? '---'}',
                      style: theme.textRegular13Subtle,
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref) async {
    try {
      final onboardingService = ref.read(onboardingServiceProvider);
      await onboardingService.resetOnboarding();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Đã reset thành công. Khởi động lại ứng dụng để xem lại hướng dẫn.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi reset hướng dẫn.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

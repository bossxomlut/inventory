import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/helpers/currency_config.dart';
import '../../domain/entities/permission/permission.dart';
import '../../domain/entities/user/user.dart';
import '../../provider/index.dart';
import '../../provider/permissions.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';
import '../onboarding/onboarding_service.dart';
import 'app_review_utils.dart';
import 'provider/currency_settings_provider.dart';

@RoutePage()
class SettingPage extends WidgetByDeviceTemplate {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final authState = ref.watch(authControllerProvider);
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final currencyAsync = ref.watch(currencySettingsControllerProvider);
    final currencySubtitle = currencyAsync.when(
      data: (unit) => _currencyDisplayName(context, unit),
      loading: () => '...',
      error: (_, __) => '---',
    );
    final bool isAdmin = authState.maybeWhen(
      authenticated: (user, _) => user.role == UserRole.admin,
      orElse: () => false,
    );

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
          // Only show "Quản lý dữ liệu" section for admin and guest users
          if (canAccessDataManagement) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LText(
                LKey.settingDataManagement,
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
                    title: const LText(LKey.settingCreateFromSample),
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
                    title: const LText(LKey.settingExportData),
                    onTap: () {
                      appRouter.goToExportData();
                    },
                  ),
                  if (isAdmin) ...[
                    const _Divider(),
                    ListTile(
                      leading: const Icon(Icons.cloud_sync),
                      title: const Text('Google Drive (Products)'),
                      onTap: () {
                        appRouter.goToDriveProductSync();
                      },
                    ),
                  ],
                  const _Divider(),
                  ListTile(
                    leading: const Icon(HugeIcons.strokeRoundedDatabaseSetting),
                    title: const LText(LKey.settingDeleteData),
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
            child: LText(
              LKey.settingPreferences,
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
                  leading: const Icon(Icons.currency_exchange),
                  title: const LText(LKey.accountCurrency),
                  subtitle: Text(currencySubtitle),
                  onTap: () => _showCurrencyPicker(
                    context,
                    ref,
                    currencyAsync.valueOrNull ?? CurrencyUnit.vnd,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LText(
              LKey.settingAboutApp,
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
                  title: const LText(LKey.settingUserGuide),
                  onTap: () {
                    appRouter.goToUserGuide();
                  },
                ),
                const _Divider(),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const LText(LKey.settingLanguage),
                  subtitle: Text(_languageDisplayName(context, context.locale)),
                  onTap: () => _showLanguagePicker(context),
                ),
                const _Divider(),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const LText(LKey.settingFeedback),
                  subtitle: const LText(LKey.settingFeedbackSubtitle),
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
                        title: const LText(LKey.settingReviewApp),
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
                    title: const LText(LKey.settingReplayOnboarding),
                    subtitle: const LText(LKey.settingReplayOnboardingSubtitle),
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
                      '${LKey.appVersion.tr(context: context)}: ${snapshot.data?.version ?? '---'}',
                      style: theme.textRegular13Subtle,
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  String _currencyDisplayName(BuildContext context, CurrencyUnit unit) {
    switch (unit) {
      case CurrencyUnit.usd:
        return LKey.accountCurrencyUsd.tr(context: context);
      case CurrencyUnit.vnd:
      default:
        return LKey.accountCurrencyVnd.tr(context: context);
    }
  }

  String _languageDisplayName(BuildContext context, Locale locale) {
    switch (locale.languageCode) {
      case 'vi':
        return LKey.languageVietnamese.tr(context: context);
      default:
        return LKey.languageEnglish.tr(context: context);
    }
  }

  Future<void> _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    CurrencyUnit currentUnit,
  ) async {
    final result = await _CurrencyPickerSheet(
      selected: currentUnit,
    ).show(context);

    if (result == null || result == currentUnit) {
      return;
    }

    await ref
        .read(currencySettingsControllerProvider.notifier)
        .setCurrencyUnit(result);
  }

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref) async {
    try {
      final onboardingService = ref.read(onboardingServiceProvider);
      await onboardingService.resetOnboarding();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(LKey.settingResetOnboardingSuccess.tr(context: context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(LKey.settingResetOnboardingError.tr(context: context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    const options = <_LanguageOption>[
      _LanguageOption(
          locale: Locale('en', 'US'), nameKey: LKey.languageEnglish),
      _LanguageOption(
          locale: Locale('vi', 'VN'), nameKey: LKey.languageVietnamese),
    ];

    final selectedLocale = context.locale;
    final result = await _LanguagePickerSheet(
      options: options,
      selectedLocale: selectedLocale,
    ).show(context);

    if (result == null || result.languageCode == selectedLocale.languageCode) {
      return;
    }

    await context.setLocale(result);
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

class _LanguagePickerSheet extends StatelessWidget
    with ShowBottomSheet<Locale> {
  const _LanguagePickerSheet({
    required this.options,
    required this.selectedLocale,
  });

  final List<_LanguageOption> options;
  final Locale selectedLocale;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                LKey.settingLanguage.tr(context: context),
                style: theme.headingSemibold20Default,
              ),
            ),
            const Divider(height: 0),
            ...options.map(
              (option) => ListTile(
                title: Text(option.nameKey.tr(context: context)),
                trailing:
                    option.locale.languageCode == selectedLocale.languageCode
                        ? const Icon(Icons.check)
                        : null,
                onTap: () => Navigator.of(context).pop(option.locale),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.nameKey,
  });

  final Locale locale;
  final String nameKey;
}

class _CurrencyPickerSheet extends StatelessWidget
    with ShowBottomSheet<CurrencyUnit> {
  const _CurrencyPickerSheet({
    required this.selected,
  });

  final CurrencyUnit selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                LKey.accountCurrency.tr(context: context),
                style: theme.headingSemibold20Default,
              ),
            ),
            const Divider(height: 0),
            for (final unit in supportedCurrencyUnits)
              ListTile(
                title: Text(
                  unit == CurrencyUnit.usd
                      ? LKey.accountCurrencyUsd.tr(context: context)
                      : LKey.accountCurrencyVnd.tr(context: context),
                ),
                trailing: unit == selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(unit),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/repositories/pin_code_repository.dart';
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
    final pinCodeRepository = ref.read(pinCodeRepositoryProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LKey.setting.tr(context: context),
      ),
      body: ListView(
        children: [
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
                // HookBuilder(builder: (context) {
                //   final isPinCodeEnabled = useState(false);
                //
                //   void loadPinCode() {
                //     pinCodeRepository.isSetPinCode.then((value) => isPinCodeEnabled.value = value);
                //   }
                //
                //   useEffect(() {
                //     loadPinCode();
                //
                //     //
                //     void listen(String? value) {
                //       pinCodeRepository.isSetPinCode.then((value) => isPinCodeEnabled.value = value);
                //     }
                //
                //     pinCodeRepository.listenPinCodeChange(listen);
                //     return () {
                //       pinCodeRepository.removePinCodeListener();
                //     };
                //   }, []);
                //
                //   return ListTile(
                //     leading: const Icon(HugeIcons.strokeRoundedLockPassword),
                //     title: const Text(
                //       'Pin Code',
                //       style: TextStyle(fontSize: 16),
                //     ),
                //     trailing: IgnorePointer(
                //       child: Switch(
                //         value: isPinCodeEnabled.value,
                //         onChanged: (_) {},
                //       ),
                //     ),
                //     onTap: () {
                //       if (isPinCodeEnabled.value) {
                //         final pinCode = ref.read(pinCodeRepositoryProvider);
                //         pinCode.logout();
                //         isPinCodeEnabled.value = false;
                //       } else {
                //         appRouter.goToPinCode();
                //       }
                //     },
                //   );
                // }),
                // const _Divider(),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/auth/auth_state.dart';
import '../../provider/index.dart';
import '../../provider/init_provider.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import 'provider/login_provider.dart';
import 'widget/default_admin_account_widget.dart';

@RoutePage()
class LoginPage extends WidgetByDeviceTemplate {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HookBuilder(
      builder: (BuildContext context) {
        useEffect(() {
          // Check and show admin dialog on first load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndShowAdminDialog(context, ref);
          });
        }, []);

        return super.build(context, ref);
      },
    );
  }

  @override
  Widget buildMobile(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: buildCommon(context, ref),
    );
  }

  @override
  Widget buildTablet(BuildContext context, WidgetRef ref) {
    return Material(
      color: context.appTheme.colorBackground,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: buildCommon(context, ref),
        ),
      ),
    );
  }

  @override
  Widget buildCommon(BuildContext context, WidgetRef ref) {
    return HookBuilder(
      builder: (context) {
        final loginState = ref.watch(loginControllerProvider);
        final userNameController = useTextEditingController(text: loginState.userName);
        final passwordController = useTextEditingController(text: loginState.password);

        useEffect(() {
          if (userNameController.text != loginState.userName) {
            userNameController.value = TextEditingValue(
              text: loginState.userName,
              selection: TextSelection.collapsed(offset: loginState.userName.length),
            );
          }
          if (passwordController.text != loginState.password) {
            passwordController.value = TextEditingValue(
              text: loginState.password,
              selection: TextSelection.collapsed(offset: loginState.password.length),
            );
          }
          return null;
        }, [loginState.userName, loginState.password]);

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              LText(LKey.login, style: context.appTheme.headingSemibold28Default),
              Gap(20),
              CustomTextField(
                label: LKey.signUpAccount.tr(context: context),
                controller: userNameController,
                onChanged: ref.read(loginControllerProvider.notifier).updateUserName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              CustomTextField.password(
                label: LKey.signUpPassword.tr(context: context),
                controller: passwordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => ref.read(loginControllerProvider.notifier).login(),
                onChanged: ref.read(loginControllerProvider.notifier).updatePassword,
              ),
              const Gap(16),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    appRouter.goToForgotPassword();
                  },
                  child: LText(
                    LKey.buttonForgotPassword,
                  ),
                ),
              ),
              const Gap(30),
              AppButton.primary(
                title: LKey.login.tr(context: context),
                onPressed: loginState.isValid ? ref.read(loginControllerProvider.notifier).login : null,
              ),
              const Gap(8),
              AppButton.ghost(
                title: '_',
                onPressed: () {
                  appRouter.goToSignUp();
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: LKey.buttonDontHaveAnAccount.tr(context: context),
                        style: context.appTheme.textRegular15Subtle,
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: LKey.buttonSignUp.tr(context: context),
                        style: context.appTheme.textRegular15Subtle.copyWith(
                          color: context.appTheme.colorPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkAndShowAdminDialog(BuildContext context, WidgetRef ref) async {
    ref.read(hasShownAdminDialogServiceProvider).checkNeedToShowDialog().then(
      (bool needToShow) {
        if (needToShow && context.mounted) {
          const DefaultAdminAccountWidget().show(context, padding: EdgeInsets.zero);
        }
      },
    );
  }
}

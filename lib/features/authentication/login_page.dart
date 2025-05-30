import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/index.dart';
import '../../provider/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import 'provider/login_provider.dart';

@RoutePage()
class LoginPage extends WidgetByDeviceTemplate {
  LoginPage({super.key});

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
    final loginState = ref.watch(loginControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 100),
          LText(LKey.login, style: context.appTheme.headingSemibold28Default),
          Gap(20),
          //text field for username
          CustomTextField(
            label: LKey.signUpAccount.tr(context: context),
            onChanged: ref.read(loginControllerProvider.notifier).updateUserName,
            textInputAction: TextInputAction.next,
            initialValue: loginState.userName,
          ),
          const SizedBox(height: 20),
          //text field for password
          CustomTextField.password(
            label: LKey.signUpPassword.tr(context: context),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => ref.read(loginControllerProvider.notifier).login(),
            onChanged: ref.read(loginControllerProvider.notifier).updatePassword,
            initialValue: loginState.password,
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
  }
}

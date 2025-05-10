import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/entities/index.dart';
import '../../provider/theme.dart';
import '../../shared_widgets/button/button.dart';
import '../../shared_widgets/index.dart';
import 'provider/login_provider.dart';

@RoutePage()
class SignUpPage extends WidgetByDeviceTemplate {
  const SignUpPage({super.key});

  @override
  Widget buildMobile(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   title: '',
      // ),
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
    return HookBuilder(builder: (context) {
      final pageController = usePageController();
      final signUpState = ref.watch(signUpControllerProvider);

      return PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LText(
                  LKey.signUpSelectRole,
                  style: context.appTheme.headingSemibold28Default,
                ),
                const Gap(30),
                ...UserRole.values.map((role) {
                  return Column(
                    children: [
                      UserRoleWidget(
                        role: role,
                        onTap: () {
                          ref.read(signUpControllerProvider.notifier).updateRole(role);
                          switch (role) {
                            case UserRole.admin:
                            case UserRole.user:
                              pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.linear);
                            case UserRole.guest:
                            //todo: navigate to guest page
                          }
                        },
                      ),
                      const Gap(20),
                    ],
                  );
                }),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LText(LKey.signUpNewPartnerRegistration, style: context.appTheme.headingSemibold28Default),
                    Gap(20),
                    //text field for username
                    CustomTextField(
                      label: LKey.signUpAccount.tr(context: context),
                      onChanged: ref.read(signUpControllerProvider.notifier).updateUserName,
                      textInputAction: TextInputAction.next,
                      initialValue: signUpState.userName,
                    ),
                    const SizedBox(height: 20),
                    //text field for password
                    CustomTextField.password(
                      label: LKey.signUpPassword.tr(context: context),
                      textInputAction: TextInputAction.next,
                      onChanged: ref.read(signUpControllerProvider.notifier).updatePassword,
                      initialValue: signUpState.password,
                    ),
                    const SizedBox(height: 20),
                    //text field for password
                    CustomTextField.password(
                      label: LKey.signUpConfirmPassword.tr(context: context),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => ref.read(signUpControllerProvider.notifier).signUp(),
                      onChanged: ref.read(signUpControllerProvider.notifier).updateConfirmPassword,
                      initialValue: signUpState.confirmPassword,
                    ),
                    const Gap(30),
                    AppButton.primary(
                      title: LKey.buttonDone.tr(context: context),
                      onPressed: signUpState.isValid ? ref.read(signUpControllerProvider.notifier).signUp : null,
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: BackButton(
                  onPressed: () {
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.linear,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class UserRoleWidget extends StatelessWidget {
  const UserRoleWidget({super.key, required this.role, required this.onTap});

  final UserRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // color: theme.colorBackgroundSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorBorderField,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              buildIcon(context),
              Gap(20),
              Text(
                role.name,
                style: theme.headingSemibold20Default,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIcon(BuildContext context) {
    switch (role) {
      case UserRole.admin:
        return Icon(
          HugeIcons.strokeRoundedManager,
          size: 68.0,
        );
      case UserRole.user:
        return Icon(
          HugeIcons.strokeRoundedUser02,
          size: 68.0,
        );
      case UserRole.guest:
        return Icon(
          HugeIcons.strokeRoundedAnonymous,
          size: 68.0,
        );
    }
  }
}

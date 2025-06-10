import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/entities/index.dart';
import '../../domain/repositories/auth/pin_code_repository.dart';
import '../../provider/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import 'provider/login_provider.dart';

@RoutePage()
class SignUpPage extends WidgetByDeviceTemplate {
  SignUpPage({super.key});

  @override
  Widget buildMobile(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   title: LKey.buttonSignUp.tr(context: context),
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
    final pinCode = ref.watch(pinCodeRepositoryProvider);
    final List<SecurityQuestionEntity> questions = pinCode.securityQuestions;
    final _key = GlobalKey();

    return HookBuilder(builder: (context) {
      final pageController = usePageController();
      final signUpState = ref.watch(signUpControllerProvider);
      final selectedQuestion = useState<SecurityQuestionEntity?>(null);
      final focusNode = useFocusNode();

      useEffect(() {
        ref.read(signUpControllerProvider.notifier).checkExistAdmin();
      }, []);

      return PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Gap(100),
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
                            isDisable: role == UserRole.admin && signUpState.isExistAdmin,
                            message: LKey.signUpValidateMessageAdminExist.tr(context: context),
                            onTap: () {
                              ref.read(signUpControllerProvider.notifier).updateRole(role);
                              switch (role) {
                                case UserRole.admin:
                                  if (signUpState.isExistAdmin) {
                                    showSimpleInfo(message: LKey.signUpValidateMessageAdminExist.tr(context: context));
                                  } else {
                                    pageController.nextPage(
                                        duration: Duration(milliseconds: 400), curve: Curves.linear);
                                  }
                                case UserRole.user:
                                  pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.linear);
                                case UserRole.guest:
                                //todo:
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
              SafeArea(
                child: BackButton(
                  onPressed: () {
                    appRouter.popForced();
                  },
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    Gap(100),
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
                      textInputAction: TextInputAction.next,
                      onChanged: ref.read(signUpControllerProvider.notifier).updateConfirmPassword,
                      initialValue: signUpState.confirmPassword,
                      onSubmitted: (String value) {
                        focusNode.requestFocus();
                      },
                    ),
                    const Gap(20),
                    ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<SecurityQuestionEntity>(
                        focusNode: focusNode,
                        items: questions.map((SecurityQuestionEntity question) {
                          return DropdownMenuItem<SecurityQuestionEntity>(
                            value: question,
                            child: Text(question.question),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedQuestion.value = value!;
                          ref.read(signUpControllerProvider.notifier).updateSecurityQuestionId(value.id);
                        },
                        value: selectedQuestion.value,
                        padding: EdgeInsets.zero,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: context.appTheme.colorBackgroundField,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        hint: Text(
                          LKey.addSecurityQuestion.tr(context: context),
                          style: context.appTheme.textRegular15Sublest,
                        ),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    //text field for password
                    CustomTextField(
                      label: LKey.addSecurityAnswer.tr(context: context),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => ref.read(signUpControllerProvider.notifier).signUp(),
                      onChanged: ref.read(signUpControllerProvider.notifier).updateSecurityAnswer,
                      initialValue: signUpState.confirmPassword,
                    ),
                    const Gap(30),
                    AppButton.primary(
                      title: LKey.buttonDone.tr(context: context),
                      onPressed: signUpState.isValid ? ref.read(signUpControllerProvider.notifier).signUp : null,
                    ),
                    const Gap(30),
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
  const UserRoleWidget({
    super.key,
    required this.role,
    required this.onTap,
    required this.isDisable,
    this.message,
  });

  final UserRole role;
  final VoidCallback onTap;
  final bool isDisable;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDisable ? theme.colorBackgroundSublest : theme.colorBackgroundSurface,
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
              Expanded(
                child: Text(
                  role.name,
                  style: theme.headingSemibold20Default,
                ),
              ),
              if (isDisable)
                IconButton(
                  onPressed: () {
                    showSimpleInfo(
                      message: message ?? LKey.signUpValidateMessageAdminExist.tr(context: context),
                    );
                  },
                  icon: const Icon(
                    Icons.info_outline,
                  ),
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

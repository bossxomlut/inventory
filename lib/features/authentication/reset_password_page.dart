import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_app/domain/repositories/pin_code_repository.dart';

import '../../domain/index.dart';
import '../../provider/index.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import 'provider/login_provider.dart';

@RoutePage()
class ResetPasswordPage extends WidgetByDeviceTemplate {
  ResetPasswordPage({super.key});

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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
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
        final pinCode = ref.watch(pinCodeRepositoryProvider);
        final List<SecurityQuestionEntity> questions = pinCode.securityQuestions;
        final forgotPasswordState = ref.watch(resetPasswordControllerProvider);
        final selectedQuestion = useState<SecurityQuestionEntity?>(null);
        final pageController = usePageController();
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
                    children: [
                      const SizedBox(height: 100),
                      LText(LKey.forgotPasswordTitle, style: context.appTheme.headingSemibold28Default),
                      const Gap(20),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: context.appTheme.colorBorderField,
                            width: 1,
                          ),
                          color: context.appTheme.colorBackgroundField,
                        ),
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<SecurityQuestionEntity>(
                            items: questions.map((SecurityQuestionEntity question) {
                              return DropdownMenuItem<SecurityQuestionEntity>(
                                value: question,
                                child: Text(question.question),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedQuestion.value = value!;
                              ref.read(resetPasswordControllerProvider.notifier).updateSecurityQuestionId(value.id);
                            },
                            value: selectedQuestion.value,
                            underline: const SizedBox(),
                            hint: Text(
                              LKey.addSecurityQuestion.tr(context: context),
                              style: context.appTheme.textRegular15Sublest,
                            ),
                            isExpanded: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: LKey.addSecurityAnswer.tr(context: context),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => ref.read(resetPasswordControllerProvider.notifier).checkInfo(),
                        onChanged: ref.read(resetPasswordControllerProvider.notifier).updateSecurityAnswer,
                      ),
                      const Gap(30),
                      AppButton.primary(
                        title: LKey.buttonNext.tr(context: context),
                        onPressed: forgotPasswordState.isValidSecurityInfo
                            ? () async {
                                final goToNextStep =
                                    await ref.read(resetPasswordControllerProvider.notifier).checkInfo();
                                if (goToNextStep) {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.linear,
                                  );
                                }
                              }
                            : null,
                      ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100),
                      LText(LKey.forgotPasswordDescriptionCreateNewPassword,
                          style: context.appTheme.headingSemibold28Default),
                      const Gap(20),
                      //text field for username

                      const SizedBox(height: 20),
                      //text field for password
                      CustomTextField.password(
                        label: LKey.signUpPassword.tr(context: context),
                        textInputAction: TextInputAction.next,
                        onChanged: ref.read(resetPasswordControllerProvider.notifier).updatePassword,
                      ),
                      const SizedBox(height: 20),
                      //text field for password
                      CustomTextField.password(
                        label: LKey.signUpConfirmPassword.tr(context: context),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => ref.read(resetPasswordControllerProvider.notifier).setNewPassword(),
                        onChanged: ref.read(resetPasswordControllerProvider.notifier).updateConfirmPassword,
                      ),
                      const Gap(30),
                      AppButton.primary(
                        title: LKey.buttonDone.tr(context: context),
                        onPressed: forgotPasswordState.isValidPassword
                            ? ref.read(resetPasswordControllerProvider.notifier).setNewPassword
                            : null,
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
      },
    );
  }
}

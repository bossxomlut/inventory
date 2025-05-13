import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_app/domain/repositories/pin_code_repository.dart';

import '../../domain/index.dart';
import '../../provider/index.dart';
import '../../shared_widgets/index.dart';
import 'provider/login_provider.dart';

@RoutePage()
class ForgotPasswordPage extends WidgetByDeviceTemplate {
  ForgotPasswordPage({super.key});

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
        final pinCode = ref.watch(pinCodeRepositoryProvider);
        final List<SecurityQuestionEntity> questions = pinCode.securityQuestions;
        final forgotPasswordState = ref.watch(forgotPasswordControllerProvider);
        final selectedQuestion = useState<SecurityQuestionEntity?>(null);
        final pageController = usePageController();
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
                  LText(LKey.forgotPasswordTitle, style: context.appTheme.headingSemibold28Default),
                  Gap(20),
                  //text field for username
                  CustomTextField(
                    label: LKey.signUpAccount.tr(context: context),
                    onChanged: ref.read(forgotPasswordControllerProvider.notifier).updateUserAccount,
                    textInputAction: TextInputAction.next,
                  ),
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
                          ref.read(forgotPasswordControllerProvider.notifier).updateSecurityQuestionId(value.id);
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
                    onSubmitted: (_) => ref.read(signUpControllerProvider.notifier).signUp(),
                    onChanged: ref.read(forgotPasswordControllerProvider.notifier).updateSecurityAnswer,
                  ),
                  const Gap(30),
                  AppButton.primary(
                    title: LKey.buttonNext.tr(context: context),
                    onPressed: forgotPasswordState.isValidSecurityInfo
                        ? () async {
                            final goToNextStep = await ref.read(forgotPasswordControllerProvider.notifier).checkInfo();
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
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LText(LKey.forgotPasswordDescriptionCreateNewPassword,
                          style: context.appTheme.headingSemibold28Default),
                      Gap(20),
                      //text field for username

                      const SizedBox(height: 20),
                      //text field for password
                      CustomTextField.password(
                        label: LKey.signUpPassword.tr(context: context),
                        textInputAction: TextInputAction.next,
                        onChanged: ref.read(forgotPasswordControllerProvider.notifier).updatePassword,
                      ),
                      const SizedBox(height: 20),
                      //text field for password
                      CustomTextField.password(
                        label: LKey.signUpConfirmPassword.tr(context: context),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => ref.read(forgotPasswordControllerProvider.notifier).setNewPassword(),
                        onChanged: ref.read(forgotPasswordControllerProvider.notifier).updateConfirmPassword,
                      ),
                      const Gap(30),
                      AppButton.primary(
                        title: LKey.buttonDone.tr(context: context),
                        onPressed: forgotPasswordState.isValidPassword
                            ? ref.read(forgotPasswordControllerProvider.notifier).setNewPassword
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

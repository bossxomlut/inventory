import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/auth/auth_state.dart';
import '../../provider/index.dart';
import '../../provider/init_provider.dart';
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

    // Check and show admin dialog on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowAdminDialog(context, ref);
    });

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

  Future<void> _checkAndShowAdminDialog(BuildContext context, WidgetRef ref) async {
    final hasShown = ref.watch(hasShownAdminDialogProvider);
    if (!hasShown && context.mounted) {
      _showAdminInfoDialog(context, ref);
    }
  }

  Future<void> _showAdminInfoDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Thông tin đăng nhập'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chào mừng bạn đến với ứng dụng quản lý kho!'),
            SizedBox(height: 16),
            Text('Tài khoản admin mặc định:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên đăng nhập: admin', style: TextStyle(fontFamily: 'monospace')),
                  Text('Mật khẩu: admin', style: TextStyle(fontFamily: 'monospace')),
                  Text('Câu hỏi bảo mật: ${LKey.whatIsYourFavoriteColor.tr(context: context)}',
                      style: TextStyle(fontFamily: 'monospace')),
                  Text('Câu trả lời bảo mật: red', style: TextStyle(fontFamily: 'monospace')),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('Vui lòng đổi mật khẩu và cập nhật câu hỏi bảo mật sau khi đăng nhập lần đầu.',
                style: TextStyle(color: Colors.orange[700], fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(hasShownAdminDialogProvider.notifier).setDialogShown();
              Navigator.of(context).pop();
            },
            child: Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}

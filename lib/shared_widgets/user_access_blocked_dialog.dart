import 'package:flutter/material.dart';

import '../../provider/theme.dart';
import '../../routes/app_router.dart';

class UserAccessBlockedDialog extends StatelessWidget {
  const UserAccessBlockedDialog({
    super.key,
    this.isRegistrationSuccess = false,
  });

  final bool isRegistrationSuccess;

  static Future<void> show(BuildContext context, {bool isRegistrationSuccess = false}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserAccessBlockedDialog(isRegistrationSuccess: isRegistrationSuccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isRegistrationSuccess ? Icons.check_circle : Icons.block,
            color: isRegistrationSuccess ? Colors.orange : theme.colorError,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            isRegistrationSuccess ? 'Đăng ký thành công' : 'Tài khoản bị khóa',
            style: theme.textMedium16Default.copyWith(
              color: isRegistrationSuccess ? Colors.orange : theme.colorError,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRegistrationSuccess 
              ? 'Tài khoản của bạn cần được admin kích hoạt trước khi có thể sử dụng.'
              : 'Tài khoản chưa được kích hoạt hoặc đã bị admin khóa.',
            style: theme.textRegular14Default,
          ),
          const SizedBox(height: 12),
          Text(
            'Vui lòng liên hệ với quản trị viên để được hỗ trợ.',
            style: theme.textRegular14Subtle,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Nếu là đăng ký thành công, điều hướng về màn hình đăng nhập
            if (isRegistrationSuccess) {
              appRouter.goToLogin();
            }
          },
          child: Text(
            'Đã hiểu',
            style: theme.textMedium14Default.copyWith(
              color: theme.colorPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

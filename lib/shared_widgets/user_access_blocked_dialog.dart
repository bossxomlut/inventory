import 'package:flutter/material.dart';

import '../../provider/theme.dart';
import '../../resources/string.dart';
import '../../routes/app_router.dart';
import 'localization_text.dart';

class UserAccessBlockedDialog extends StatelessWidget {
  const UserAccessBlockedDialog({
    super.key,
    this.isRegistrationSuccess = false,
  });

  final bool isRegistrationSuccess;

  static Future<void> show(BuildContext context,
      {bool isRegistrationSuccess = false}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          UserAccessBlockedDialog(isRegistrationSuccess: isRegistrationSuccess),
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
          LText(
            isRegistrationSuccess
                ? LKey.userAccessBlockedRegistrationSuccessTitle
                : LKey.userAccessBlockedBlockedTitle,
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
          LText(
            isRegistrationSuccess
                ? LKey.userAccessBlockedRegistrationDescription
                : LKey.userAccessBlockedBlockedDescription,
            style: theme.textRegular14Default,
          ),
          const SizedBox(height: 12),
          LText(
            LKey.userAccessBlockedContactAdmin,
            style: theme.textRegular14Subtle,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // If registration just completed, return to the login screen
            if (isRegistrationSuccess) {
              appRouter.goToLogin();
            }
          },
          child: LText(
            LKey.userAccessBlockedUnderstood,
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

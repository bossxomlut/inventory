import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/auth/default_admin_account.dart';
import '../../../provider/init_provider.dart';
import '../../../resources/index.dart';
import '../../../shared_widgets/dialog.dart';
import '../../../shared_widgets/index.dart';
import '../provider/login_provider.dart';

class DefaultAdminAccountWidget extends ConsumerWidget with ShowDialog {
  const DefaultAdminAccountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          LText(LKey.authDefaultAdminTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LText(LKey.authDefaultAdminWelcome),
          const SizedBox(height: 16),
          LText(
            LKey.authDefaultAdminDefaultAccount,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LKey.authDefaultAdminUsername
                      .tr(context: context, namedArgs: {'username': defaultAdminAccount.username}),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Text(
                  LKey.authDefaultAdminPassword
                      .tr(context: context, namedArgs: {'password': defaultAdminAccount.password}),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Text(
                  LKey.authDefaultAdminSecurityQuestion.tr(
                    context: context,
                    namedArgs: {
                      'question': _securityQuestionLabel(
                        context,
                        defaultAdminAccount.securityQuestionId,
                      ),
                    },
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Text(
                  LKey.authDefaultAdminSecurityAnswer
                      .tr(context: context, namedArgs: {'answer': defaultAdminAccount.securityAnswer}),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LKey.authDefaultAdminInstruction.tr(context: context),
            style: TextStyle(color: Colors.orange[700], fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final loginController = ref.read(loginControllerProvider.notifier);
            loginController
              ..updateUserName(defaultAdminAccount.username)
              ..updatePassword(defaultAdminAccount.password);
            await ref.read(hasShownAdminDialogServiceProvider).setDialogShown();
            Navigator.of(context).pop();
          },
          child: LText(LKey.authDefaultAdminUnderstood),
        ),
      ],
    );
  }

  String _securityQuestionLabel(BuildContext context, int questionId) {
    switch (questionId) {
      case 1:
        return LKey.whatIsYourFavoriteColor.tr(context: context);
      case 2:
        return LKey.whatIsYourFavoriteFood.tr(context: context);
      case 3:
        return LKey.whatIsYourFavoriteMovie.tr(context: context);
      default:
        return '';
    }
  }
}

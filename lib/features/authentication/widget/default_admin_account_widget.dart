import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/init_provider.dart';
import '../../../resources/index.dart';
import '../../../shared_widgets/dialog.dart';
import '../../../shared_widgets/index.dart';

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
                      .tr(context: context, namedArgs: {'username': 'admin'}),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Text(
                  LKey.authDefaultAdminPassword
                      .tr(context: context, namedArgs: {'password': 'admin'}),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Text(
                  LKey.authDefaultAdminSecurityQuestion.tr(
                    context: context,
                    namedArgs: {
                      'question':
                          LKey.whatIsYourFavoriteColor.tr(context: context),
                    },
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Text(
                  LKey.authDefaultAdminSecurityAnswer
                      .tr(context: context, namedArgs: {'answer': 'red'}),
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
            ref.read(hasShownAdminDialogServiceProvider).setDialogShown();
            Navigator.of(context).pop();
          },
          child: LText(LKey.authDefaultAdminUnderstood),
        ),
      ],
    );
  }
}

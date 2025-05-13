import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/index.dart';
import '../../../provider/index.dart';
import '../provider/user_provider.dart';

class UserCard extends ConsumerWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(currentIndexProvider);
    final user = ref.watch(loadUserProvider).data[index];

    final theme = context.appTheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: user.username.colorFromString,
              child: Text(
                user.username.firstLetter,
                style: theme.headingSemibold28Default,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: theme.textRegular18Default,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: user.role.name.colorFromString,
                    ),
                    child: Text(
                      user.role.name,
                      style: theme.textRegular12Inverse,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

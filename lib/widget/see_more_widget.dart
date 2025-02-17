import 'package:flutter/material.dart';

import '../resource/index.dart';
import 'index.dart';

class SeeMoreWidget extends StatelessWidget {
  const SeeMoreWidget({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return TextButton(
      onPressed: onTap,
      // style: theme.textButtonTheme.style?.copyWith(
      //   backgroundColor: MaterialStateProperty.all(theme.colorScheme.primary),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            LText(
              LKey.all,
              style: context.appTheme.textTheme.titleMedium,
            ),
            Gap(8.0),
            Icon(
              LineIcons.arrowRight,
              color: context.appTheme.textTheme.titleMedium?.color,
              size: 20,
              weight: 4,
            ),
          ],
        ),
      ),
    );
  }
}

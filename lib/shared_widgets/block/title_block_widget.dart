import 'package:flutter/material.dart';

import '../../provider/index.dart';

class TitleBlockWidget extends StatelessWidget {
  const TitleBlockWidget({
    super.key,
    required this.title,
    this.isRequired = false,
    required this.child,
  });

  final String title;
  final bool isRequired;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: theme.textRegular12Subtle,
              ),
            ),
            if (isRequired)
              Text(
                ' * ',
                style: theme.textRegular12Subtle.copyWith(
                  color: theme.colorTextSupportRed,
                ),
              ),
          ],
        ),
        const Gap(8),
        child,
      ],
    );
  }
}

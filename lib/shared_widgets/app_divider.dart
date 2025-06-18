import 'package:flutter/material.dart';

import '../provider/index.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Divider(
      height: 1,
      color: theme.colorDivider,
    );
  }
}

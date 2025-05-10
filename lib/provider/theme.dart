import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../resources/index.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.light);

  void setTheme(AppThemeMode theme) {
    state = theme;
  }
}

extension Context on BuildContext {
  // Custom call a provider for reading method only
  // It will be helpful for us for calling the read function
  // without Consumer,ConsumerWidget or ConsumerStatefulWidget
  // Incase if you face any issue using this then please wrap your widget
  // with consumer and then call your provider

  T read<T>(ProviderBase<T> provider) {
    return ProviderScope.containerOf(this, listen: false).read(provider);
  }

  AppThemeData get appTheme {
    return read(themeProvider).themeData;
  }
}

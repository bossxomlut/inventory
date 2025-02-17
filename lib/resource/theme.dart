import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/persistence/simple_key_value_storage.dart';
import '../injection/injection.dart';

class ThemeUtils {
  static ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  static void toggleThemeMode() {
    final ThemeMode themeMode = themeModeNotifier.value;
    themeModeNotifier.value = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    // Save theme mode to local storage
    SimpleStorage simpleStorage = getIt.get<SimpleStorage>();

    simpleStorage.saveString('theme_mode', themeModeNotifier.value.toString());
  }

  static Future<void> initThemeMode() async {
    SimpleStorage simpleStorage = getIt.get<SimpleStorage>();
    String? themeMode = await simpleStorage.getString('theme_mode');

    if (themeMode == null) {
      themeModeNotifier.value = ThemeMode.system;
    } else {
      themeModeNotifier.value = themeMode == 'ThemeMode.light' ? ThemeMode.light : ThemeMode.dark;
    }
  }

  static ThemeData get lightTheme {
    final lightTheme = ThemeData.light();
    return lightTheme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(lightTheme.textTheme),
    );
  }

  static ThemeData get darkTheme {
    final darkTheme = ThemeData.dark();
    return darkTheme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(darkTheme.textTheme),
    );
  }
}

extension ThemeExtension on BuildContext {
  ThemeData get appTheme {
    return Theme.of(this);
  }
}

extension ThemeDataExtension on ThemeData {
  Color get borderColor => colorScheme.onSurface.withOpacity(0.12);

  Color getWarningByCountDate(int dateCount) {
    if (dateCount <= 0) {
      return Colors.redAccent;
    } else if (dateCount < 5) {
      return Colors.orangeAccent;
    } else if (dateCount < 15) {
      return Colors.purple;
    } else if (dateCount < 30) {
      return Colors.green;
    }

    return Colors.transparent;
  }

  Color get successColor {
    return Colors.greenAccent;
  }
}

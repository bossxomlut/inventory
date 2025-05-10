import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_styles.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

extension AppThemeModeX on AppThemeMode {
  bool get isLight => this == AppThemeMode.light;
  bool get isDark => this == AppThemeMode.dark;

  AppThemeData get themeData {
    switch (this) {
      case AppThemeMode.system:
        final themeMode = AppThemeModeX.fromSystem();
        return fromTheme(themeMode);
      case AppThemeMode.light:
        return fromTheme(AppThemeMode.light);
      case AppThemeMode.dark:
        return fromTheme(AppThemeMode.dark);
    }
  }

  static AppThemeData fromTheme(AppThemeMode themeMode) {
    if (themeMode == AppThemeMode.light) {
      return _lightTheme;
    } else {
      return _darkTheme;
    }
  }

  static AppThemeMode fromString(String value) {
    try {
      switch (value.split('.').last) {
        case 'system':
          return AppThemeMode.system;
        case 'light':
          return AppThemeMode.light;
        case 'dark':
          return AppThemeMode.dark;
        default:
          return AppThemeMode.system;
      }
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  static AppThemeMode fromSystem() {
    final brightness = WidgetsBinding.instance?.window.platformBrightness;
    if (brightness == Brightness.light) {
      return AppThemeMode.light;
    } else {
      return AppThemeMode.dark;
    }
  }

  //Listen to system theme change
  static void fromBrightness() {
    WidgetsBinding.instance?.window.onPlatformBrightnessChanged = () {
      AppThemeMode themeMode = fromSystem();
    };
  }
}

const String fontFamily = 'Sansation';

/// Initializes text styles for a given theme
AppTextStyles initializeTextStyles(Color defaultTextColor) {
  return AppTextStylesImpl(fontFamily, defaultTextColor);
}

AppColors initializeColors(AppThemeMode themeMode) {
  return themeMode.isLight ? AppColors.light : AppColors.dark;
}

final _lightTheme = _buildTheme(AppThemeMode.light);
final _darkTheme = _buildTheme(AppThemeMode.dark);

AppThemeData _buildTheme(AppThemeMode themeMode) {
  final AppColors colors = initializeColors(themeMode);
  final textStyles = initializeTextStyles(colors.textDefaultColor);

  return AppThemeData(
    themeMode: themeMode,
    colorTransparent: Colors.transparent,
    colorPrimary: colors.primaryColor,
    colorPrimaryDisable: colors.primaryDisableColor,
    colorSecondary: colors.secondaryColor,
    colorTertiary: colors.tertiaryColor,
    colorTertiaryDisable: colors.tertiaryDisableColor,
    colorBackgroundBottomSheet: colors.bottomSheetBackgroundColor,
    colorBackgroundDialog: colors.dialogBackGroundColor,
    colorGhost: colors.ghostColor,
    colorBackground: colors.backgroundColor,
    colorBackgroundSublest: colors.backgroundSublestColor,
    colorBackGroundBottomBar: colors.bottomBarBackgroundColor,
    colorDynamicBlack: colors.dynamicBlackColor,
    colorDynamicBlack80: colors.dynamicBlack80Color,
    colorBackgroundField: colors.backgroundFieldColor,
    colorBackgroundFieldDisable: colors.backgroundFieldDisableColor,
    colorBackgroundSurface: colors.backgroundSurfaceColor,
    colorBorderField: colors.borderFieldColor,
    colorBorderSublest: colors.borderSublestColor,
    colorBorderSubtle: colors.borderSubtleColor,
    colorDivider: colors.dividerColor,
    colorDisabled: colors.disabledColor,
    colorError: colors.errorColor,
    colorIcon: colors.iconColor,
    colorIconSublest: colors.iconColorSublest,
    colorIconSubtle: colors.iconColorSubtle,
    colorIconDisable: colors.iconColorDisable,
    colorTextDefault: colors.textDefaultColor,
    colorTextDisable: colors.textDisableColor,
    colorTextPrimary: colors.textPrimaryColor,
    colorTextInverse: colors.textInverseColor,
    colorTextSubtle: colors.textSubtleColor,
    colorTextSublest: colors.textSublestColor,
    colorTextWhite: colors.textWhiteColor,
    colorIndicator: colors.indicatorColor,
    colorIndicatorPlaceholder: colors.indicatorPlaceholderColor,
    colorTextSupportGreen: colors.textSupportGreenColor,
    colorTextSupportRed: colors.textSupportRedColor,
    colorTextSupportBlue: colors.textSupportBlueColor,
    colorBackgroundBlue: colors.backgroundBlueColor,
    colorBackgroundMa: colors.backgroundMaColor,

    // Buttons
    buttonRegular12: textStyles.buttonRegular12,
    buttonSemibold12: textStyles.buttonSemibold12,
    buttonSemibold13: textStyles.buttonSemibold13,
    buttonSemibold15: textStyles.buttonSemibold15,
    buttonRegular14: textStyles.buttonRegular14,
    buttonMedium14: textStyles.buttonMedium14,
    buttonSemibold14: textStyles.buttonSemibold14,

    // Default Text Styles
    textRegular10Default: textStyles.textRegular10,
    textRegular12Default: textStyles.textRegular12,
    textRegular13Default: textStyles.textRegular13,
    textMedium13Default: textStyles.textMedium13,
    textRegular14Default: textStyles.textRegular14,
    textMedium14Default: textStyles.textMedium14,
    textRegular15Default: textStyles.textRegular15,
    textMedium15Default: textStyles.textMedium15,
    textRegular16Default: textStyles.textRegular16,
    textMedium16Default: textStyles.textMedium16,
    textRegular18Default: textStyles.textRegular18,
    headingSemibold20Default: textStyles.headingSemibold20,
    headingSemibold24Default: textStyles.headingSemibold24,
    headingSemibold28Default: textStyles.headingSemibold28,
    headingSemibold32Default: textStyles.headingSemibold32,
    headingSemibold48Default: textStyles.headingSemibold48,
    headingSemibold64Default: textStyles.headingSemibold64,

    // Subtle Variants
    textRegular10Subtle: textStyles.textRegular10.copyWith(color: colors.textSubtleColor),
    textRegular12Subtle: textStyles.textRegular12.copyWith(color: colors.textSubtleColor),
    textRegular13Subtle: textStyles.textRegular13.copyWith(color: colors.textSubtleColor),
    textMedium13Subtle: textStyles.textMedium13.copyWith(color: colors.textSubtleColor),
    textRegular14Subtle: textStyles.textRegular14.copyWith(color: colors.textSubtleColor),
    textMedium14Subtle: textStyles.textMedium14.copyWith(color: colors.textSubtleColor),
    textRegular15Subtle: textStyles.textRegular15.copyWith(color: colors.textSubtleColor),
    textMedium15Subtle: textStyles.textMedium15.copyWith(color: colors.textSubtleColor),
    textRegular16Subtle: textStyles.textRegular16.copyWith(color: colors.textSubtleColor),
    textMedium16Subtle: textStyles.textMedium16.copyWith(color: colors.textSubtleColor),
    textRegular18Subtle: textStyles.textRegular18.copyWith(color: colors.textSubtleColor),
    headingSemibold20Subtle: textStyles.headingSemibold20.copyWith(color: colors.textSubtleColor),
    headingSemibold24Subtle: textStyles.headingSemibold24.copyWith(color: colors.textSubtleColor),
    headingSemibold28Subtle: textStyles.headingSemibold28.copyWith(color: colors.textSubtleColor),
    headingSemibold32Subtle: textStyles.headingSemibold32.copyWith(color: colors.textSubtleColor),
    headingSemibold48Subtle: textStyles.headingSemibold48.copyWith(color: colors.textSubtleColor),
    headingSemibold64Subtle: textStyles.headingSemibold64.copyWith(color: colors.textSubtleColor),

    // Inverse Variants
    textRegular10Inverse: textStyles.textRegular10.copyWith(color: colors.textInverseColor),
    textRegular12Inverse: textStyles.textRegular12.copyWith(color: colors.textInverseColor),
    textRegular13Inverse: textStyles.textRegular13.copyWith(color: colors.textInverseColor),
    textMedium13Inverse: textStyles.textMedium13.copyWith(color: colors.textInverseColor),
    textRegular14Inverse: textStyles.textRegular14.copyWith(color: colors.textInverseColor),
    textMedium14Inverse: textStyles.textMedium14.copyWith(color: colors.textInverseColor),
    textRegular15Inverse: textStyles.textRegular15.copyWith(color: colors.textInverseColor),
    textMedium15Inverse: textStyles.textMedium15.copyWith(color: colors.textInverseColor),
    textRegular16Inverse: textStyles.textRegular16.copyWith(color: colors.textInverseColor),
    textMedium16Inverse: textStyles.textMedium16.copyWith(color: colors.textInverseColor),
    textRegular18Inverse: textStyles.textRegular18.copyWith(color: colors.textInverseColor),
    headingSemibold20Inverse: textStyles.headingSemibold20.copyWith(color: colors.textInverseColor),
    headingSemibold24Inverse: textStyles.headingSemibold24.copyWith(color: colors.textInverseColor),
    headingSemibold28Inverse: textStyles.headingSemibold28.copyWith(color: colors.textInverseColor),
    headingSemibold32Inverse: textStyles.headingSemibold32.copyWith(color: colors.textInverseColor),
    headingSemibold48Inverse: textStyles.headingSemibold48.copyWith(color: colors.textInverseColor),
    headingSemibold64Inverse: textStyles.headingSemibold64.copyWith(color: colors.textInverseColor),

    // Primary Variants
    textRegular10Primary: textStyles.textRegular10.copyWith(color: colors.textPrimaryColor),
    textRegular12Primary: textStyles.textRegular12.copyWith(color: colors.textPrimaryColor),
    textRegular13Primary: textStyles.textRegular13.copyWith(color: colors.textPrimaryColor),
    textMedium13Primary: textStyles.textMedium13.copyWith(color: colors.textPrimaryColor),
    textRegular14Primary: textStyles.textRegular14.copyWith(color: colors.textPrimaryColor),
    textMedium14Primary: textStyles.textMedium14.copyWith(color: colors.textPrimaryColor),
    textRegular15Primary: textStyles.textRegular15.copyWith(color: colors.textPrimaryColor),
    textMedium15Primary: textStyles.textMedium15.copyWith(color: colors.textPrimaryColor),
    textRegular16Primary: textStyles.textRegular16.copyWith(color: colors.textPrimaryColor),
    textMedium16Primary: textStyles.textMedium16.copyWith(color: colors.textPrimaryColor),
    textRegular18Primary: textStyles.textRegular18.copyWith(color: colors.textPrimaryColor),
    headingSemibold20Primary: textStyles.headingSemibold20.copyWith(color: colors.textPrimaryColor),
    headingSemibold24Primary: textStyles.headingSemibold24.copyWith(color: colors.textPrimaryColor),
    headingSemibold28Primary: textStyles.headingSemibold28.copyWith(color: colors.textPrimaryColor),
    headingSemibold32Primary: textStyles.headingSemibold32.copyWith(color: colors.textPrimaryColor),
    headingSemibold48Primary: textStyles.headingSemibold48.copyWith(color: colors.textPrimaryColor),
    headingSemibold64Primary: textStyles.headingSemibold64.copyWith(color: colors.textPrimaryColor),

    // Sublest Variants
    textRegular10Sublest: textStyles.textRegular10.copyWith(color: colors.textSublestColor),
    textRegular12Sublest: textStyles.textRegular12.copyWith(color: colors.textSublestColor),
    textRegular13Sublest: textStyles.textRegular13.copyWith(color: colors.textSublestColor),
    textMedium13Sublest: textStyles.textMedium13.copyWith(color: colors.textSublestColor),
    textRegular14Sublest: textStyles.textRegular14.copyWith(color: colors.textSublestColor),
    textMedium14Sublest: textStyles.textMedium14.copyWith(color: colors.textSublestColor),
    textRegular15Sublest: textStyles.textRegular15.copyWith(color: colors.textSublestColor),
    textMedium15Sublest: textStyles.textMedium15.copyWith(color: colors.textSublestColor),
    textRegular16Sublest: textStyles.textRegular16.copyWith(color: colors.textSublestColor),
    textMedium16Sublest: textStyles.textMedium16.copyWith(color: colors.textSublestColor),
    textRegular18Sublest: textStyles.textRegular18.copyWith(color: colors.textSublestColor),
    headingSemibold20Sublest: textStyles.headingSemibold20.copyWith(color: colors.textSublestColor),
    headingSemibold24Sublest: textStyles.headingSemibold24.copyWith(color: colors.textSublestColor),
    headingSemibold28Sublest: textStyles.headingSemibold28.copyWith(color: colors.textSublestColor),
    headingSemibold32Sublest: textStyles.headingSemibold32.copyWith(color: colors.textSublestColor),
    headingSemibold48Sublest: textStyles.headingSemibold48.copyWith(color: colors.textSublestColor),
    headingSemibold64Sublest: textStyles.headingSemibold64.copyWith(color: colors.textSublestColor),
  );
}

class AppThemeData {
  AppThemeData({
    required this.themeMode,
    required this.colorTransparent,
    required this.colorPrimary,
    required this.colorPrimaryDisable,
    required this.colorSecondary,
    required this.colorTertiary,
    required this.colorTertiaryDisable,
    required this.colorBackgroundBottomSheet,
    required this.colorBackgroundDialog,
    required this.colorGhost,
    required this.colorBackground,
    required this.colorBackgroundSublest,
    required this.colorDynamicBlack,
    required this.colorDynamicBlack80,
    required this.colorBackgroundField,
    required this.colorBackgroundFieldDisable,
    required this.colorBackgroundSurface,
    required this.colorBackGroundBottomBar,
    required this.colorBorderField,
    required this.colorBorderSublest,
    required this.colorBorderSubtle,
    required this.colorDivider,
    required this.colorDisabled,
    required this.colorTextDefault,
    required this.colorTextDisable,
    required this.colorTextPrimary,
    required this.colorTextInverse,
    required this.colorTextSubtle,
    required this.colorTextSublest,
    required this.colorTextWhite,
    required this.colorIndicator,
    required this.colorError,
    required this.colorIcon,
    required this.colorIconSublest,
    required this.colorIconSubtle,
    required this.colorIconDisable,
    required this.colorIndicatorPlaceholder,
    required this.colorTextSupportGreen,
    required this.colorTextSupportRed,
    required this.colorTextSupportBlue,
    required this.colorBackgroundBlue,
    required this.colorBackgroundMa,
    required this.buttonRegular12,
    required this.buttonSemibold12,
    required this.buttonSemibold13,
    required this.buttonSemibold15,
    required this.buttonRegular14,
    required this.buttonMedium14,
    required this.buttonSemibold14,
    required this.textRegular10Default,
    required this.textRegular12Default,
    required this.textRegular13Default,
    required this.textMedium13Default,
    required this.textRegular14Default,
    required this.textMedium14Default,
    required this.textRegular15Default,
    required this.textMedium15Default,
    required this.textRegular16Default,
    required this.textMedium16Default,
    required this.textRegular18Default,
    required this.headingSemibold20Default,
    required this.headingSemibold24Default,
    required this.headingSemibold28Default,
    required this.headingSemibold32Default,
    required this.headingSemibold48Default,
    required this.headingSemibold64Default,
    required this.textRegular10Subtle,
    required this.textRegular12Subtle,
    required this.textRegular13Subtle,
    required this.textMedium13Subtle,
    required this.textRegular14Subtle,
    required this.textMedium14Subtle,
    required this.textRegular15Subtle,
    required this.textMedium15Subtle,
    required this.textRegular16Subtle,
    required this.textMedium16Subtle,
    required this.textRegular18Subtle,
    required this.headingSemibold20Subtle,
    required this.headingSemibold24Subtle,
    required this.headingSemibold28Subtle,
    required this.headingSemibold32Subtle,
    required this.headingSemibold48Subtle,
    required this.headingSemibold64Subtle,
    required this.textRegular10Inverse,
    required this.textRegular12Inverse,
    required this.textRegular13Inverse,
    required this.textMedium13Inverse,
    required this.textRegular14Inverse,
    required this.textMedium14Inverse,
    required this.textRegular15Inverse,
    required this.textMedium15Inverse,
    required this.textRegular16Inverse,
    required this.textMedium16Inverse,
    required this.textRegular18Inverse,
    required this.headingSemibold20Inverse,
    required this.headingSemibold24Inverse,
    required this.headingSemibold28Inverse,
    required this.headingSemibold32Inverse,
    required this.headingSemibold48Inverse,
    required this.headingSemibold64Inverse,
    required this.textRegular10Primary,
    required this.textRegular12Primary,
    required this.textRegular13Primary,
    required this.textMedium13Primary,
    required this.textRegular14Primary,
    required this.textMedium14Primary,
    required this.textRegular15Primary,
    required this.textMedium15Primary,
    required this.textRegular16Primary,
    required this.textMedium16Primary,
    required this.textRegular18Primary,
    required this.headingSemibold20Primary,
    required this.headingSemibold24Primary,
    required this.headingSemibold28Primary,
    required this.headingSemibold32Primary,
    required this.headingSemibold48Primary,
    required this.headingSemibold64Primary,
    required this.textRegular10Sublest,
    required this.textRegular12Sublest,
    required this.textRegular13Sublest,
    required this.textMedium13Sublest,
    required this.textRegular14Sublest,
    required this.textMedium14Sublest,
    required this.textRegular15Sublest,
    required this.textMedium15Sublest,
    required this.textRegular16Sublest,
    required this.textMedium16Sublest,
    required this.textRegular18Sublest,
    required this.headingSemibold20Sublest,
    required this.headingSemibold24Sublest,
    required this.headingSemibold28Sublest,
    required this.headingSemibold32Sublest,
    required this.headingSemibold48Sublest,
    required this.headingSemibold64Sublest,
  });

  final AppThemeMode themeMode;
  final Color colorTransparent;
  final Color colorPrimary;
  final Color colorPrimaryDisable;
  final Color colorSecondary;
  final Color colorTertiary;
  final Color colorTertiaryDisable;
  final Color colorBackgroundBottomSheet;
  final Color colorBackgroundDialog;
  final Color colorGhost;
  final Color colorBackground;
  final Color colorBackgroundSublest;
  final Color colorDynamicBlack;
  final Color colorDynamicBlack80;
  final Color colorBackgroundField;
  final Color colorBackgroundFieldDisable;
  final Color colorBackgroundSurface;
  final Color colorBackGroundBottomBar;
  final Color colorBorderField;
  final Color colorBorderSublest;
  final Color colorBorderSubtle;
  final Color colorDivider;
  final Color colorDisabled;
  final Color colorTextDefault;
  final Color colorTextDisable;
  final Color colorTextPrimary;
  final Color colorTextInverse;
  final Color colorTextSubtle;
  final Color colorTextSublest;
  final Color colorTextWhite;
  final Color colorIndicator;
  final Color colorError;
  final Color colorIcon;
  final Color colorIconSublest;
  final Color colorIconSubtle;
  final Color colorIconDisable;
  final Color colorIndicatorPlaceholder;
  final Color colorTextSupportGreen;
  final Color colorTextSupportRed;
  final Color colorTextSupportBlue;
  final Color colorBackgroundBlue;
  final Color colorBackgroundMa;
  final TextStyle buttonRegular12;
  final TextStyle buttonSemibold12;
  final TextStyle buttonSemibold13;
  final TextStyle buttonSemibold15;
  final TextStyle buttonRegular14;
  final TextStyle buttonMedium14;
  final TextStyle buttonSemibold14;
  final TextStyle textRegular10Default;
  final TextStyle textRegular12Default;
  final TextStyle textRegular13Default;
  final TextStyle textMedium13Default;
  final TextStyle textRegular14Default;
  final TextStyle textMedium14Default;
  final TextStyle textRegular15Default;
  final TextStyle textMedium15Default;
  final TextStyle textRegular16Default;
  final TextStyle textMedium16Default;
  final TextStyle textRegular18Default;
  final TextStyle headingSemibold20Default;
  final TextStyle headingSemibold24Default;
  final TextStyle headingSemibold28Default;
  final TextStyle headingSemibold32Default;
  final TextStyle headingSemibold48Default;
  final TextStyle headingSemibold64Default;
  final TextStyle textRegular10Subtle;
  final TextStyle textRegular12Subtle;
  final TextStyle textRegular13Subtle;
  final TextStyle textMedium13Subtle;
  final TextStyle textRegular14Subtle;
  final TextStyle textMedium14Subtle;
  final TextStyle textRegular15Subtle;
  final TextStyle textMedium15Subtle;
  final TextStyle textRegular16Subtle;
  final TextStyle textMedium16Subtle;
  final TextStyle textRegular18Subtle;
  final TextStyle headingSemibold20Subtle;
  final TextStyle headingSemibold24Subtle;
  final TextStyle headingSemibold28Subtle;
  final TextStyle headingSemibold32Subtle;
  final TextStyle headingSemibold48Subtle;
  final TextStyle headingSemibold64Subtle;
  final TextStyle textRegular10Inverse;
  final TextStyle textRegular12Inverse;
  final TextStyle textRegular13Inverse;
  final TextStyle textMedium13Inverse;
  final TextStyle textRegular14Inverse;
  final TextStyle textMedium14Inverse;
  final TextStyle textRegular15Inverse;
  final TextStyle textMedium15Inverse;
  final TextStyle textRegular16Inverse;
  final TextStyle textMedium16Inverse;
  final TextStyle textRegular18Inverse;
  final TextStyle headingSemibold20Inverse;
  final TextStyle headingSemibold24Inverse;
  final TextStyle headingSemibold28Inverse;
  final TextStyle headingSemibold32Inverse;
  final TextStyle headingSemibold48Inverse;
  final TextStyle headingSemibold64Inverse;
  final TextStyle textRegular10Primary;
  final TextStyle textRegular12Primary;
  final TextStyle textRegular13Primary;
  final TextStyle textMedium13Primary;
  final TextStyle textRegular14Primary;
  final TextStyle textMedium14Primary;
  final TextStyle textRegular15Primary;
  final TextStyle textMedium15Primary;
  final TextStyle textRegular16Primary;
  final TextStyle textMedium16Primary;
  final TextStyle textRegular18Primary;
  final TextStyle headingSemibold20Primary;
  final TextStyle headingSemibold24Primary;
  final TextStyle headingSemibold28Primary;
  final TextStyle headingSemibold32Primary;
  final TextStyle headingSemibold48Primary;
  final TextStyle headingSemibold64Primary;
  final TextStyle textRegular10Sublest;
  final TextStyle textRegular12Sublest;
  final TextStyle textRegular13Sublest;
  final TextStyle textMedium13Sublest;
  final TextStyle textRegular14Sublest;
  final TextStyle textMedium14Sublest;
  final TextStyle textRegular15Sublest;
  final TextStyle textMedium15Sublest;
  final TextStyle textRegular16Sublest;
  final TextStyle textMedium16Sublest;
  final TextStyle textRegular18Sublest;
  final TextStyle headingSemibold20Sublest;
  final TextStyle headingSemibold24Sublest;
  final TextStyle headingSemibold28Sublest;
  final TextStyle headingSemibold32Sublest;
  final TextStyle headingSemibold48Sublest;
  final TextStyle headingSemibold64Sublest;

  Color getDraggableBackgroundColor() {
    switch (themeMode) {
      case AppThemeMode.light:
        return Colors.white.withOpacity(0.5);
      case AppThemeMode.dark:
        return Colors.black.withOpacity(0.8);
      case AppThemeMode.system:
        final brightness = WidgetsBinding.instance?.window.platformBrightness;
        return brightness == Brightness.light ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.8);
    }
  }
}

ThemeData dTheme(BuildContext context, AppThemeData theme) {
  final baseTheme = ThemeData.light();

  return baseTheme.copyWith(
    scaffoldBackgroundColor: theme.colorBackground,
    cupertinoOverrideTheme: baseTheme.cupertinoOverrideTheme?.copyWith(
      primaryColor: theme.colorPrimary,
    ),
    primaryColor: theme.colorPrimary,
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: theme.colorPrimary,
      onPrimary: Colors.white,
    ),
    timePickerTheme: baseTheme.timePickerTheme.copyWith(hourMinuteColor: theme.colorPrimary.withAlpha(60)),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: theme.colorPrimary,
      selectionColor: theme.colorPrimary,
      selectionHandleColor: theme.colorPrimary,
    ),
    canvasColor: theme.colorBackgroundSurface,
  );
}

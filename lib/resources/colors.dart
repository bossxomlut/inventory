import 'package:flutter/material.dart';

abstract class AppColors {
  static AppColors get dark => DarkColors();

  static AppColors get light => LightColors();

  Color get backgroundColor;
  Color get backgroundSublestColor;
  Color get primaryColor;
  Color get primaryDisableColor;
  Color get secondaryColor;
  Color get tertiaryColor;
  Color get tertiaryDisableColor;
  Color get bottomSheetBackgroundColor;
  Color get dialogBackGroundColor;
  Color get bottomBarBackgroundColor;
  Color get ghostColor;
  Color get backgroundFieldColor;
  Color get backgroundFieldDisableColor;
  Color get backgroundSurfaceColor;
  Color get borderFieldColor;
  Color get borderSublestColor;
  Color get borderSubtleColor;
  Color get dividerColor;
  Color get disabledColor;
  Color get textDefaultColor;
  Color get textDisableColor;
  Color get textInverseColor;
  Color get textPrimaryColor;
  Color get textColor;
  Color get textSubtleColor;
  Color get textSublestColor;
  Color get textWhiteColor;
  Color get indicatorColor;
  Color get indicatorPlaceholderColor;
  Color get iconColor;
  Color get iconColorSublest;
  Color get iconColorSubtle;
  Color get iconColorDisable;
  Color get textSupportGreenColor;
  Color get textSupportRedColor;
  Color get textSupportBlueColor;
  Color get backgroundBlueColor;
  Color get backgroundMaColor;
  Color get dynamicBlackColor;
  Color get dynamicBlack80Color;
  Color get errorColor;
}

class DarkColors implements AppColors {
  @override
  Color get backgroundColor => const Color(0xFF0f0f0f);
  @override
  Color get backgroundSublestColor => const Color(0xFF2E2E2E);
  @override
  Color get primaryColor => const Color(0xFF09553E);
  @override
  Color get primaryDisableColor => const Color(0xFF3D3D3D);
  @override
  Color get secondaryColor => const Color(0x1AFFFFFF);
  @override
  Color get tertiaryColor => const Color(0xFF2E2E2E);
  @override
  Color get tertiaryDisableColor => const Color(0xFF1E1E1E);
  @override
  Color get bottomSheetBackgroundColor => const Color(0xFF1E1E1E);
  @override
  Color get dialogBackGroundColor => const Color(0xFF1E1E1E);
  @override
  Color get bottomBarBackgroundColor => const Color(0xFF1E1E1E);
  @override
  Color get ghostColor => Colors.transparent;
  @override
  Color get backgroundFieldColor => const Color(0x0DFFFFFF);
  @override
  Color get backgroundFieldDisableColor => const Color(0xFF163632).withOpacity(0.05);
  @override
  Color get backgroundSurfaceColor => const Color(0xFF1E1E1E);
  @override
  Color get borderFieldColor => const Color(0x1AFFFFFF);
  @override
  Color get borderSublestColor => const Color(0x0DFFFFFF);
  @override
  Color get borderSubtleColor => const Color(0x1AFFFFFF);
  @override
  Color get dividerColor => const Color(0x0DFFFFFF);
  @override
  Color get textDefaultColor => const Color(0xFFEBEBEB);
  @override
  Color get textDisableColor => const Color(0xFF7A7A7A);
  @override
  Color get textInverseColor => const Color(0xE5000000);
  @override
  Color get textPrimaryColor => const Color(0xFF498572);
  @override
  Color get textColor => const Color(0xFFEBEBEB);
  @override
  Color get textSubtleColor => const Color(0xFFB2B2B2);
  @override
  Color get textSublestColor => const Color(0xFFB2B2B2);
  @override
  Color get textWhiteColor => Colors.white;
  @override
  Color get indicatorColor => const Color(0xFF09553E);
  @override
  Color get indicatorPlaceholderColor => const Color(0x1AFFFFFF);
  @override
  Color get iconColor => const Color(0xFFEBEBEB);
  @override
  Color get iconColorSublest => const Color(0xFF8F8F8F);
  @override
  Color get iconColorSubtle => const Color(0xFFB2B2B2);
  @override
  Color get iconColorDisable => const Color(0xFF7A7A7A);
  @override
  Color get textSupportGreenColor => const Color(0xFF64CB16);
  @override
  Color get textSupportRedColor => const Color(0xFFEE514F);
  @override
  Color get textSupportBlueColor => const Color(0xFF0A84FF);
  @override
  Color get backgroundMaColor => const Color(0x1F4DBAB2);
  @override
  Color get backgroundBlueColor => const Color(0x1F2163FD);
  @override
  Color get dynamicBlackColor => const Color(0x0DFFFFFF);
  @override
  Color get dynamicBlack80Color => const Color(0xFF525252);
  @override
  Color get errorColor => const Color(0xFFCE1612);

  @override
  Color get disabledColor => const Color(0xFF3D3D3D);
}

class LightColors implements AppColors {
  @override
  Color get backgroundColor => const Color(0xFFf2f1f0);
  @override
  Color get backgroundSublestColor => const Color(0xFFF5F5F5);
  @override
  Color get primaryColor => const Color(0xFF09553E);
  @override
  Color get primaryDisableColor => const Color(0xFFE0E0E0);
  @override
  Color get secondaryColor => const Color(0xFFE4F5EF);
  @override
  Color get tertiaryColor => const Color(0xFF2E2E2E);
  @override
  Color get tertiaryDisableColor => const Color(0xFF1E1E1E);
  @override
  Color get bottomSheetBackgroundColor => const Color(0xFFFFFFFF);
  @override
  Color get dialogBackGroundColor => const Color(0xFFd5d5d5);
  @override
  Color get bottomBarBackgroundColor => const Color(0xFFFBFBFB);
  @override
  Color get ghostColor => Colors.transparent;
  @override
  Color get backgroundFieldColor => const Color(0xFFFAFAFA);
  @override
  Color get backgroundFieldDisableColor => const Color(0xFFF5F5F5).withOpacity(0.05);
  @override
  Color get backgroundSurfaceColor => Colors.white;
  @override
  Color get borderFieldColor => const Color(0xFFE0E0E0);
  @override
  Color get borderSublestColor => const Color(0xFFF5F5F5);
  @override
  Color get borderSubtleColor => const Color(0xFFEBEBEB);
  @override
  Color get dividerColor => const Color(0xFFEBEBEB);
  @override
  Color get textDefaultColor => Color(0xFF1E1E1E);
  @override
  Color get textDisableColor => const Color(0xFFA3A3A3);
  @override
  Color get textInverseColor => const Color(0xE5000000);
  @override
  Color get textPrimaryColor => const Color(0xFF09553E);
  @override
  Color get textColor => const Color(0xFFEBEBEB);
  @override
  Color get textSubtleColor => const Color(0xFF666666);
  @override
  Color get textSublestColor => const Color(0xFF8F8F8F);
  @override
  Color get textWhiteColor => Colors.white;
  @override
  Color get indicatorColor => const Color(0xFF09553E);
  @override
  Color get indicatorPlaceholderColor => const Color(0xFFD1D1D1);
  @override
  Color get iconColor => const Color(0xFF666666);
  @override
  Color get iconColorSublest => const Color(0xFF8F8F8F);
  @override
  Color get iconColorSubtle => const Color(0xFF666666);
  @override
  Color get iconColorDisable => const Color(0xFF7A7A7A);
  @override
  Color get textSupportGreenColor => const Color(0xFF64CB16);
  @override
  Color get textSupportRedColor => const Color(0xFFEE514F);
  @override
  Color get textSupportBlueColor => const Color(0xFF007AFF);
  @override
  Color get backgroundMaColor => const Color(0xFFE4F5EF);
  @override
  Color get dynamicBlackColor => const Color(0xFFF5F5F5);
  @override
  Color get backgroundBlueColor => const Color(0xFFF1F5FE);
  @override
  Color get dynamicBlack80Color => const Color(0xFFc6c6c6);
  @override
  Color get errorColor => const Color(0xFFCE1612);

  @override
  Color get disabledColor => const Color(0xFF3D3D3D);
}

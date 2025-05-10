import 'package:flutter/cupertino.dart';

abstract class AppTextStyles {
  AppTextStyles(this.font, this.defaultColor);
  final String font;
  final Color defaultColor;
  TextStyle get buttonRegular12;
  TextStyle get buttonSemibold12;
  TextStyle get buttonSemibold13;
  TextStyle get buttonSemibold15;
  TextStyle get buttonRegular14;
  TextStyle get buttonMedium14;
  TextStyle get buttonSemibold14;
  TextStyle get textRegular10;
  TextStyle get textRegular12;
  TextStyle get textRegular13;
  TextStyle get textMedium13;
  TextStyle get textRegular14;
  TextStyle get textMedium14;
  TextStyle get textRegular15;
  TextStyle get textMedium15;
  TextStyle get textRegular16;
  TextStyle get textMedium16;
  TextStyle get textRegular18;
  TextStyle get headingSemibold20;
  TextStyle get headingSemibold24;
  TextStyle get headingSemibold28;
  TextStyle get headingSemibold32;
  TextStyle get headingSemibold48;
  TextStyle get headingSemibold64;
}

class AppTextStylesImpl extends AppTextStyles {
  AppTextStylesImpl(super.font, super.defaultColor);

  @override
  TextStyle get buttonRegular12 => TextStyle(
        fontFamily: font,
        fontSize: 12,
        height: 14.4 / 12,
        color: defaultColor,
      );

  @override
  TextStyle get buttonSemibold12 => TextStyle(
        fontFamily: font,
        fontSize: 12,
        height: 14.4 / 12,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get buttonSemibold13 => TextStyle(
        fontFamily: font,
        fontSize: 13,
        height: 16.38 / 13,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get buttonSemibold15 => TextStyle(
        fontFamily: font,
        fontSize: 15,
        height: 18.9 / 15,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get buttonRegular14 => TextStyle(
        fontFamily: font,
        fontSize: 14,
        height: 16.8 / 14,
        color: defaultColor,
      );

  @override
  TextStyle get buttonMedium14 => TextStyle(
        fontFamily: font,
        fontSize: 14,
        height: 16.8 / 14,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      );

  @override
  TextStyle get buttonSemibold14 => TextStyle(
        fontFamily: font,
        fontSize: 14,
        height: 16.8 / 14,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get textRegular10 => TextStyle(
        fontFamily: font,
        fontSize: 10,
        height: 12 / 10,
        color: defaultColor,
      );

  @override
  TextStyle get textRegular12 => TextStyle(
        fontFamily: font,
        fontSize: 12,
        height: 14.4 / 12,
        color: defaultColor,
      );

  @override
  TextStyle get textRegular13 => TextStyle(
        fontFamily: font,
        fontSize: 13,
        height: 15.6 / 13,
        color: defaultColor,
      );

  @override
  TextStyle get textMedium13 => TextStyle(
        fontFamily: font,
        fontSize: 13,
        height: 15.6 / 13,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      );

  @override
  TextStyle get textRegular14 => TextStyle(
        fontFamily: font,
        fontSize: 14,
        height: 16.8 / 14,
        color: defaultColor,
      );

  @override
  TextStyle get textMedium14 => TextStyle(
        fontFamily: font,
        fontSize: 14,
        height: 16.8 / 14,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      );

  @override
  TextStyle get textRegular15 => TextStyle(
        fontFamily: font,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 20 / 15,
        color: defaultColor,
      );

  @override
  TextStyle get textMedium15 => TextStyle(
        fontFamily: font,
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      );

  @override
  TextStyle get textRegular16 => TextStyle(
        fontFamily: font,
        fontSize: 16,
        height: 22.4 / 16,
        color: defaultColor,
      );

  @override
  TextStyle get textMedium16 => TextStyle(
        fontFamily: font,
        fontSize: 16,
        height: 22.4 / 16,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      );

  @override
  TextStyle get textRegular18 => TextStyle(
        fontFamily: font,
        fontSize: 18,
        height: 23.4 / 18,
        color: defaultColor,
      );

  @override
  TextStyle get headingSemibold20 => TextStyle(
        fontFamily: font,
        fontSize: 20,
        height: 24 / 20,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get headingSemibold24 => TextStyle(
        fontFamily: font,
        fontSize: 24,
        height: 28.8 / 24,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get headingSemibold28 => TextStyle(
        fontFamily: font,
        fontSize: 28,
        height: 33.6 / 28,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get headingSemibold32 => TextStyle(
        fontFamily: font,
        fontSize: 32,
        height: 38.4 / 32,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get headingSemibold48 => TextStyle(
        fontFamily: font,
        fontSize: 48,
        height: 57.6 / 48,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );

  @override
  TextStyle get headingSemibold64 => TextStyle(
        fontFamily: font,
        fontSize: 64,
        height: 76.8 / 64,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      );
}

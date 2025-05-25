import 'package:flutter/material.dart';

extension StringX on String? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }

  bool get isNotNullOrEmpty {
    return !isNullOrEmpty;
  }

  bool get isUrl {
    if (this.isNullOrEmpty) {
      return false;
    }

    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = new RegExp(pattern);

    return regExp.hasMatch(this!);
  }

  bool get isSystemPath {
    return this?.startsWith('i_protect/') ?? false;
  }

  //first letter of string
  String get firstLetter {
    return getFirstLetter(this ?? '');
  }

  //two first letters of two strings
  String get twoFirstLetters {
    final parts = this?.split(' ') ?? [];
    if (parts.length < 2) {
      return getFirstLetter(this ?? '');
    }
    return getTwoFirstLetters(parts[0], parts[1]);
  }

  //get color from string
  Color get colorFromString {
    return getColorFromString(this ?? '');
  }

  //get text style from string
  Color get colorTextStyle {
    return getColorTextStyle(this ?? '');
  }

  //get background color from string
  Color get backgroundColorFromString {
    return colorFromString.withOpacity(0.1); // Adjust opacity for background
  }
}

//get first letter of username
String getFirstLetter(String str) {
  if (str.isEmpty) {
    return 'UNKN';
  }
  return str[0].toUpperCase();
}

//get two first letters of two text from string
String getTwoFirstLetters(String str1, String str2) {
  final firstLetter = str1.isNotEmpty ? str1[0].toUpperCase() : 'U';
  final secondLetter = str2.isNotEmpty ? str2[0].toUpperCase() : 'N';
  return '$firstLetter$secondLetter';
}

Color getColorFromString(String str) {
  if (str.isEmpty) {
    return Colors.grey;
  }
  final int hash = str.hashCode;
  final int r = (hash & 0xFF0000) >> 16;
  final int g = (hash & 0x00FF00) >> 8;
  final int b = hash & 0x0000FF;
  return Color.fromARGB(255, r, g, b);
}

//get color from string for text style
Color getColorTextStyle(String str) {
  final color = getColorFromString(str);
  return color.withOpacity(0.8); // Adjust opacity for text style
}

//get color from string for background color
Color getBackgroundColorFromString(String str) {
  final color = getColorFromString(str);
  return color.withOpacity(0.1); // Adjust opacity for background
}

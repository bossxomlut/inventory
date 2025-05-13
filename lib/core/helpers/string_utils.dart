import 'package:flutter/material.dart';

extension StringUtils on String? {
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
    if (isNullOrEmpty) {
      return 'UNKN';
    }
    return this![0].toUpperCase();
  }

  //get color from string
  Color get colorFromString {
    return getColorFromString(this ?? '');
  }
}

//get first letter of username
String getFirstLetter(String str) {
  if (str.isEmpty) {
    return 'UNKN';
  }
  return str[0].toUpperCase();
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

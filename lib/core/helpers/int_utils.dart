import 'package:flutter/material.dart';

extension ColorIntX on int {
  Color? get color {
    if (isOdd) {
      return Colors.grey.withAlpha(50);
    }
    return null;
  }
}

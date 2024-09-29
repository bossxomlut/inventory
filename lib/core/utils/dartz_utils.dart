import 'package:dartz/dartz.dart';

extension OptionOf on Option<dynamic> {
  static Option<T> value<T>(T? value) {
    return value == null ? const None() : Some<T>(value);
  }
}

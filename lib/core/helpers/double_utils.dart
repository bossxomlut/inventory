import 'package:intl/intl.dart';

extension DoubleX on double? {
  /// Formats a double value as currency with specified locale and decimal digits.
  /// - [decimalDigits]: Number of decimal digits (default: 0 for VND, 2 for others).
  /// - [locale]: Locale for formatting (default: 'vi_VN' for VND).
  /// - [currencySymbol]: Optional currency symbol (default: '₫' for VND).
  String priceFormat({
    int decimalDigits = 2,
    String locale = 'vi_VN',
    String currencySymbol = '₫',
  }) {
    if (this == null) {
      return '---';
    } else if (this == 0) {
      return '0$currencySymbol';
    }

    // Check if the number is effectively an integer (e.g., 200.0)
    final effectiveDecimalDigits = (this! % 1 == 0) ? 0 : decimalDigits;

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currencySymbol,
      decimalDigits: effectiveDecimalDigits,
    );

    return formatter.format(this);
  }
}

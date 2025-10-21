import 'package:intl/intl.dart';

import 'currency_config.dart';

extension DoubleX on double? {
  /// Formats a double value as currency with specified locale and decimal digits.
  /// - [decimalDigits]: Number of decimal digits (default: 0 for VND, 2 for others).
  /// - [locale]: Locale for formatting (default: 'vi_VN' for VND).
  /// - [currencySymbol]: Optional currency symbol (default: '₫' for VND).
  String priceFormat({
    int? decimalDigits,
    String? locale,
    String? currencySymbol,
  }) {
    if (this == null) {
      return '---';
    }

    final display = CurrencySettingsHolder.current;
    final symbol = currencySymbol ?? display.symbol;
    final useLocale = locale ?? display.locale;
    final configuredDecimalDigits = decimalDigits ?? display.decimalDigits;
    final isSymbolOnRight = display.symbolOnRight;

    // Check if the number is effectively an integer (e.g., 200.0)
    final effectiveDecimalDigits =
        (this! % 1 == 0) ? 0 : configuredDecimalDigits;

    final formatter = NumberFormat.currency(
      locale: useLocale,
      symbol: isSymbolOnRight ? '' : symbol,
      decimalDigits: effectiveDecimalDigits,
    );

    final formatted = formatter.format(this).trim();
    if (isSymbolOnRight) {
      final base = formatted.isEmpty ? '0' : formatted;
      return '$base $symbol'.trim();
    }
    return formatted.isEmpty ? symbol : formatted;
  }
}

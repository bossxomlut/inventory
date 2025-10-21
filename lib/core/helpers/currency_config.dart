enum CurrencyUnit { vnd, usd }

class CurrencyDisplay {
  const CurrencyDisplay({
    required this.symbol,
    required this.symbolOnRight,
    required this.locale,
    required this.decimalDigits,
  });

  final String symbol;
  final bool symbolOnRight;
  final String locale;
  final int decimalDigits;

  CurrencyDisplay copyWith({
    String? symbol,
    bool? symbolOnRight,
    String? locale,
    int? decimalDigits,
  }) {
    return CurrencyDisplay(
      symbol: symbol ?? this.symbol,
      symbolOnRight: symbolOnRight ?? this.symbolOnRight,
      locale: locale ?? this.locale,
      decimalDigits: decimalDigits ?? this.decimalDigits,
    );
  }
}

extension CurrencyUnitX on CurrencyUnit {
  static CurrencyUnit fromStorageValue(String? value) {
    switch (value) {
      case 'usd':
        return CurrencyUnit.usd;
      case 'vnd':
      default:
        return CurrencyUnit.vnd;
    }
  }

  String get storageValue {
    switch (this) {
      case CurrencyUnit.usd:
        return 'usd';
      case CurrencyUnit.vnd:
        return 'vnd';
    }
  }

  CurrencyDisplay get display {
    switch (this) {
      case CurrencyUnit.usd:
        return const CurrencyDisplay(
          symbol: '\$',
          symbolOnRight: false,
          locale: 'en_US',
          decimalDigits: 2,
        );
      case CurrencyUnit.vnd:
        return const CurrencyDisplay(
          symbol: 'đ',
          symbolOnRight: true,
          locale: 'vi_VN',
          decimalDigits: 0,
        );
    }
  }
}

class CurrencySettingsHolder {
  static CurrencyDisplay _current = CurrencyUnit.vnd.display;

  static CurrencyDisplay get current => _current;

  static set current(CurrencyDisplay value) {
    _current = value;
  }
}

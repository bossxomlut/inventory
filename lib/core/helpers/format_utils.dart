import 'package:intl/intl.dart';

extension AmountFormat on num {
  String displayFormat({int? decimalDigits}) {
    if (this == null) {
      return '';
    } else if (this == 0) {
      //nếu không check case này thì có thể -0
      return '0';
    }

    return NumberFormat("#,##0.###", 'en_US').format(this);
  }

  String inputFormat({int? decimalDigits}) {
    //just show number
    //if is double seprate by , at decimal
    return NumberFormat("###0.###", "en_US").format(this);
  }
}

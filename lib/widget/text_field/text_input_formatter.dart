import 'package:flutter/services.dart';

const String _dot = '.';
const String _comma = ',';

///Đặt giới hạn 3 số thập phân
class DotTextInputFormatter extends TextInputFormatter {
  DotTextInputFormatter({this.fractionDigits = 3});

  final int fractionDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String inputText = newValue.text;

    final _numberSplit = inputText.split(_dot);
    String float = _numberSplit.length == 2 ? _numberSplit.last : '';

    if (_numberSplit.length > 2) {
      return oldValue;
    }

    if (float.length > fractionDigits) {
      return oldValue;
    }
    return newValue;
  }
}

class ThousandTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String inputText = newValue.text;

    final _numberSplit = inputText.split(_dot);
    String integer = _numberSplit.first.replaceAll(_comma, '');
    String float = _numberSplit.length >= 2 ? _numberSplit[1] : '';

    if (integer.length > 1) {
      if (integer[0] == '0') {
        integer = integer.substring(1);
      }
    }

    String formatText = splitUnit(integer).join(_comma);
    if (_numberSplit.length >= 2) {
      formatText = '$formatText$_dot';
      if (float.isNotEmpty) {
        formatText = '$formatText$float';
      }
    }

    final oldValueTextLength = oldValue.text.length;
    final formattedTextLength = formatText.length;
    return TextEditingValue(
      text: formatText,
      selection: TextSelection.fromPosition(
        TextPosition(
          offset: oldValue.selection.extentOffset + (formattedTextLength - oldValueTextLength),
        ),
      ),
    );
  }
}

List<String> splitUnit(String number) {
  int length = number.length;
  int currentIndex = length;
  List<String> results = [];
  while (currentIndex > 0) {
    int preIndex = currentIndex - 3;
    results.insert(0, number.substring(preIndex >= 0 ? preIndex : 0, currentIndex));
    currentIndex = preIndex >= 0 ? preIndex : 0;
  }
  return results;
}

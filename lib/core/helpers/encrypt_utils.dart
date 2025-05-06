class PinCodeEncryptUtils {
  // Bảng ánh xạ từ số sang chữ cái
  static const List<String> _numberToLetterMapping = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

  // Bảng ánh xạ ngược từ chữ cái về số
  static const Map<String, String> _letterToNumberMapping = {
    'A': '0',
    'B': '1',
    'C': '2',
    'D': '3',
    'E': '4',
    'F': '5',
    'G': '6',
    'H': '7',
    'I': '8',
    'J': '9',
  };

  /// Mã hóa chuỗi số thành chuỗi chữ cái, thêm 2 ký tự
  static String encryptToLettersWithExtra(String input) {
    // Kiểm tra xem input có phải toàn số không
    if (!RegExp(r'^\d+$').hasMatch(input)) {
      throw ArgumentError('Input must contain only digits.');
    }

    // Mã hóa phần chính (có tính đến index)
    String encryptedCore = input.split('').asMap().entries.map((entry) {
      int index = entry.key;
      int digit = int.parse(entry.value);
      int newDigit = (digit + index) % 10;
      return _numberToLetterMapping[newDigit];
    }).join();

    // Tính toán 2 ký tự bổ sung
    int sumOfDigits = input.split('').map(int.parse).reduce((a, b) => a + b);
    int extra1 = (sumOfDigits) % 10; // Ký tự đầu tiên thêm
    int extra2 = (sumOfDigits + 5) % 10; // Ký tự thứ hai thêm
    String extraChars = _numberToLetterMapping[extra1] + _numberToLetterMapping[extra2]; // Chuyển thành chữ cái

    return encryptedCore + extraChars;
  }

  /// Giải mã chuỗi chữ cái về chuỗi số, xử lý 2 ký tự thêm
  static String decryptToNumbersWithExtra(String input) {
    // Kiểm tra xem input có phải toàn chữ cái hợp lệ không
    if (!RegExp(r'^[A-J]+$').hasMatch(input)) {
      throw ArgumentError('Input must contain only letters from A to J.');
    }

    // Loại bỏ 2 ký tự cuối (phần bổ sung)
    String core = input.substring(0, input.length - 2);

    // Giải mã phần chính (có tính đến index)
    return core.split('').asMap().entries.map((entry) {
      int index = entry.key;
      String letter = entry.value;
      int originalDigit = (_letterToNumberMapping[letter]!.toInt() - index + 10) % 10;
      return originalDigit.toString();
    }).join();
  }
}

extension StringExtension on String {
  int toInt() => int.parse(this);
}

void main() {
  // Ví dụ sử dụng
  String original = "1231";
  String encrypted = PinCodeEncryptUtils.encryptToLettersWithExtra(original);
  String decrypted = PinCodeEncryptUtils.decryptToNumbersWithExtra(encrypted);

  print("Chuỗi ban đầu: $original");
  print("Chuỗi mã hóa: $encrypted");
  print("Chuỗi giải mã: $decrypted");
}

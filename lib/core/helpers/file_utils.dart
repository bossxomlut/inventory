import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hàm lấy đường dẫn đến thư mục lưu trữ tài liệu của ứng dụng.
Future<String> getFilePath(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  //print
  print('${directory.path}/$fileName');
  return '${directory.path}/$fileName';
}

/// Kiểm tra tồn tại file
Future<bool> checkFileExists(String fileName) async {
  try {
    final filePath = await getFilePath(fileName);
    final file = File(filePath);
    return file.existsSync();
  } catch (e) {
    return false;
  }
}

/// Tạo file
Future<File> createFile(String fileName) async {
  final filePath = await getFilePath(fileName);
  final file = File(filePath);
  return file.create();
}

/// Xóa file
Future<void> deleteFile(String fileName) async {
  final filePath = await getFilePath(fileName);
  final file = File(filePath);
  return file.deleteSync();
}

/// 📌 Chuyển đổi ảnh thành chuỗi Base64
Future<String> convertImageToBase64(String imagePath) async {
  File imageFile = File(imagePath);

  if (!await imageFile.exists()) {
    throw Exception("⚠️ File không tồn tại!");
  }

  List<int> imageBytes = await imageFile.readAsBytes();
  return base64Encode(imageBytes);
}

/// 📌 Chuyển đổi chuỗi Base64 thành file ảnh
Future<void> convertBase64ToImage(String base64String, String outputPath) async {
  List<int> imageBytes = base64Decode(base64String);
  File outputFile = File(outputPath);
  await outputFile.writeAsBytes(imageBytes);
}

/// 📌 Chuyển Base64 thành `XFile`
Future<XFile> convertBase64ToXFile(String base64String, {String fileName = "temp_image.png"}) async {
  // Giải mã chuỗi Base64 thành bytes
  Uint8List imageBytes = base64Decode(base64String);

  // Lưu file vào thư mục tạm thời
  Directory tempDir = await getTemporaryDirectory();
  String filePath = "${tempDir.path}/$fileName";

  File imageFile = File(filePath);
  await imageFile.writeAsBytes(imageBytes);

  return XFile(imageFile.path); // Trả về `XFile`
}

DateTime getModifiedTime(File file) {
  final stat = FileStat.statSync(file.path);

  return stat.modified;
}

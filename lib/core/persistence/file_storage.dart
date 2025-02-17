import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> saveFileToLocalDirectory(File file) async {
  // Lấy thư mục cục bộ của ứng dụng
  final directory = await getApplicationDocumentsDirectory();

  // Lấy tên file gốc
  final fileName = path.basename(file.path);

  // Tạo đường dẫn mới trong thư mục cục bộ
  final localPath = path.join(directory.path, fileName);

  // Sao chép file vào đường dẫn mới
  final savedFile = await file.copy(localPath);

  return savedFile.path; // Trả về đường dẫn file đã lưu
}

Future<bool> isInternalPath(String filePath) async {
  // Lấy thư mục nội bộ của ứng dụng
  final internalDir = (await getApplicationDocumentsDirectory()).path;

  // Kiểm tra đường dẫn file có nằm trong thư mục nội bộ không
  return filePath.startsWith(internalDir);
}

import 'dart:io';

import 'package:csv/csv.dart';

import '../utils/file_utils.dart';

/// Đọc dữ liệu từ file CSV và chuyển đổi thành List<List<dynamic>>
Future<List<List<dynamic>>> readCsvFile(String fileName) async {
  final path = await getFilePath(fileName);
  final file = File(path);

  // Nếu file không tồn tại, trả về danh sách chứa header (nếu có) hoặc danh sách rỗng
  if (!await file.exists()) {
    return [];
  }

  return readCsvRow(file);
}

Future<List<List<dynamic>>> readCsvRow(File file) async {
  final contents = await file.readAsString();
  List<List<dynamic>> rows = const CsvToListConverter().convert(contents);
  return rows;
}

/// Ghi dữ liệu từ List<List<dynamic>> vào file CSV
Future<void> writeCsvFile(String fileName, List<List<dynamic>> rows) async {
  if (!(await checkFileExists(fileName))) {
    await createFile(fileName);
  }

  final path = await getFilePath(fileName);

  String csv = const ListToCsvConverter().convert(rows);
  final file = File(path);

  await file.writeAsString(csv);
}

/// Thêm một dòng dữ liệu mới vào cuối file CSV
Future<void> appendCsvRecord(String fileName, List<dynamic> newRecord, {required List<String> header}) async {
  // Đọc dữ liệu hiện có
  List<List<dynamic>> rows = await readCsvFile(fileName);

  // Nếu file không tồn tại hoặc rỗng, bạn có thể thêm header trước khi thêm dòng dữ liệu mới.
  // Ví dụ: nếu file chưa có header, ta có thể tạo header theo model của bạn
  if (rows.isEmpty) {
    rows.add(header);
  }

  // Thêm dòng dữ liệu mới vào cuối danh sách
  rows.add(newRecord);

  // Ghi lại toàn bộ dữ liệu vào file CSV
  await writeCsvFile(fileName, rows);
}

/// Xoá một dòng dữ liệu trong file CSV theo index
Future<void> deleteCsvRecord(String fileName, int rowIndex) async {
  List<List<dynamic>> rows = await readCsvFile(fileName);

  if (rowIndex < 0 || rowIndex >= rows.length) {
    print("⚠️ Không thể xoá: Chỉ mục không hợp lệ.");
    return;
  }

  rows.removeAt(rowIndex); // Xoá dòng dữ liệu theo chỉ mục

  await writeCsvFile(fileName, rows);
  print("✅ Xoá dòng $rowIndex thành công.");
}

/// Cập nhật một dòng dữ liệu trong file CSV
Future<void> updateCsvRecord(String fileName, int rowIndex, List<dynamic> updatedRecord) async {
  List<List<dynamic>> rows = await readCsvFile(fileName);

  if (rowIndex < 0 || rowIndex >= rows.length) {
    print("⚠️ Không thể cập nhật: Chỉ mục không hợp lệ.");
    return;
  }

  rows[rowIndex] = updatedRecord; // Cập nhật dòng dữ liệu

  await writeCsvFile(fileName, rows);
  print("✅ Cập nhật dòng $rowIndex thành công.");
}

/// Tìm kiếm dữ liệu trong file CSV
Future<List<List<dynamic>>> searchCsvRecords(String fileName, dynamic keyword, {int? columnIndex}) async {
  List<List<dynamic>> rows = await readCsvFile(fileName);
  List<List<dynamic>> results = [];

  for (var row in rows) {
    if (columnIndex != null) {
      // Tìm trong cột cụ thể
      if (columnIndex < row.length && row[columnIndex].toString().contains(keyword.toString())) {
        results.add(row);
      }
    } else {
      // Tìm trong toàn bộ hàng
      if (row.any((cell) => cell.toString().contains(keyword.toString()))) {
        results.add(row);
      }
    }
  }

  return results;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

final fileImportServiceProvider = Provider<FileImportService>((ref) {
  return FileImportService();
});

class ImportResult {
  final bool success;
  final String message;
  final List<String> details;

  ImportResult({
    required this.success,
    required this.message,
    this.details = const [],
  });
}

class FileImportService {
  Future<ImportResult> selectAndImportFile() async {
    try {
      // Simulate file selection and import process
      await Future<void>.delayed(const Duration(seconds: 2));
      
      // Simulate random success/failure for demo
      final random = DateTime.now().millisecond % 100;
      
      if (random < 20) {
        // 20% failure due to invalid format
        return ImportResult(
          success: false,
          message: 'File không đúng định dạng.',
          details: [
            'File không chứa các phần dữ liệu bắt buộc',
            'Hãy sử dụng file được xuất từ ứng dụng này',
            'Các định dạng hỗ trợ: JSON, Excel, CSV'
          ],
        );
      } else if (random < 40) {
        // 20% failure due to data validation
        return ImportResult(
          success: false,
          message: 'Dữ liệu không hợp lệ.',
          details: [
            'Phát hiện 5 mục dữ liệu không đúng định dạng',
            'Thiếu thông tin bắt buộc trong một số bản ghi',
            'Vui lòng kiểm tra lại file dữ liệu'
          ],
        );
      } else {
        // 60% success
        return ImportResult(
          success: true,
          message: 'Nhập dữ liệu thành công!',
          details: [
            'Cửa hàng: 3/3 mục',
            'Danh mục: 15/16 mục (1 mục bị trùng)',
            'Sản phẩm: 125/130 mục (5 mục không hợp lệ)',
            'Hóa đơn: 45/45 mục',
            'Tổng cộng: 188/194 mục được nhập thành công'
          ],
        );
      }
      
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Có lỗi xảy ra khi xử lý file.',
        details: [e.toString()],
      );
    }
  }
  
  Future<ImportResult> selectFile() async {
    // Simulate file selection only
    await Future<void>.delayed(const Duration(seconds: 1));
    
    return ImportResult(
      success: true,
      message: 'File đã được chọn: sample_data.json (2.3 MB)',
      details: [
        'Định dạng: JSON',
        'Kích thước: 2.3 MB',
        'Chứa: shops, categories, inventory_items, invoices'
      ],
    );
  }
}

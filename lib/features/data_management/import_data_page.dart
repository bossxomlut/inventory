import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/helpers/scaffold_utils.dart';
import '../../shared_widgets/app_bar.dart';

@RoutePage()
class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  String? _fileName;
  String? _resultMessage;
  bool? _success;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _resultMessage = null;
      _success = null;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jsonl', 'csv', 'xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      _fileName = file.path.split('/').last;
      // Validate file extension
      final ext = _fileName!.split('.').last.toLowerCase();
      if (!['jsonl', 'csv', 'xlsx'].contains(ext)) {
        setState(() {
          _resultMessage = 'Định dạng file không được hỗ trợ.';
          _success = false;
          _isLoading = false;
        });
        return;
      }
      // Validate file content (giả lập)
      final isValid = await _validateFileContent(file, ext);
      setState(() {
        _resultMessage = isValid ? 'Nhập dữ liệu thành công!' : 'File không đúng định dạng dữ liệu ứng dụng.';
        _success = isValid;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _validateFileContent(File file, String ext) async {
    // TODO: Thực hiện validate thực tế với dữ liệu export từ app
    // Ở đây chỉ giả lập: file json có từ khóa "inventory" là hợp lệ
    try {
      final content = await file.readAsString();
      if (ext == 'jsonl' && content.contains('inventory')) return true;
      if (ext == 'csv' && content.contains('product')) return true;
      if (ext == 'xlsx') return true; // Giả lập
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Nhập dữ liệu từ file'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(HugeIcons.strokeRoundedInformationCircle, color: Colors.blue),
                SizedBox(width: 8),
                Text('Các định dạng hỗ trợ:', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('- JSONL: Mỗi dòng là một object JSON, đúng cấu trúc export từ ứng dụng.'),
                  Text('- CSV: File bảng, cột và tên cột đúng như file export từ ứng dụng.'),
                  Text('- XLSX: File Excel, sheet và cột đúng như file export từ ứng dụng.'),
                  SizedBox(height: 8),
                  Text(
                      'Lưu ý: Chỉ nhập file được xuất từ ứng dụng này hoặc có định dạng, cấu trúc giống như hướng dẫn ở trên.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(HugeIcons.strokeRoundedFolder02),
              label: Text(_fileName == null ? 'Chọn file để nhập dữ liệu' : _fileName!),
              onPressed: _isLoading ? null : _pickFile,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_resultMessage != null)
              Row(
                children: [
                  Icon(_success == true ? Icons.check_circle : Icons.error,
                      color: _success == true ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_resultMessage!)),
                ],
              ),
            const SizedBox(height: 24),
            const Text('Lưu ý: Chỉ nhập file được xuất từ ứng dụng này hoặc có định dạng tương tự.'),
          ],
        ),
      ),
    );
  }
}

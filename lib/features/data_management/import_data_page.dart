import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/helpers/scaffold_utils.dart';
import '../../resources/index.dart';
import '../../shared_widgets/app_bar.dart';
import '../../shared_widgets/data_import_result_dialog.dart';
import 'services/data_import_service.dart';

@RoutePage()
class ImportDataPage extends ConsumerStatefulWidget {
  const ImportDataPage({super.key});

  @override
  ConsumerState<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends ConsumerState<ImportDataPage> {
  String? _fileName;
  String? _resultMessage;
  bool? _success;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final context = this.context;
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);
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
          _resultMessage =
              t(LKey.dataManagementImportResultUnsupported);
          _success = false;
          _isLoading = false;
        });
        return;
      }
      if (ext == 'xlsx') {
        try {
          final importService = ref.read(dataImportServiceProvider);
          final bytes = await file.readAsBytes();
          final result = await importService.importFromExcelBytes(bytes);
          if (context.mounted) {
            await DataImportResultDialog.showResult(
              context,
              result,
              title: 'Kết quả nhập dữ liệu Excel',
            );
          }
          setState(() {
            _resultMessage = result.success
                ? t(LKey.dataManagementImportResultSuccess)
                : t(LKey.dataManagementImportResultInvalid);
            _success = result.success;
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _resultMessage = 'Lỗi nhập Excel: $e';
            _success = false;
            _isLoading = false;
          });
        }
        return;
      }

      // Validate file content (giả lập cho jsonl/csv)
      final isValid = await _validateFileContent(file, ext);
      setState(() {
        _resultMessage = isValid
            ? t(LKey.dataManagementImportResultSuccess)
            : t(LKey.dataManagementImportResultInvalid);
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
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);
    return Scaffold(
      appBar: CustomAppBar(title: t(LKey.dataManagementImportTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(HugeIcons.strokeRoundedInformationCircle, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  t(LKey.dataManagementImportFormatsTitle),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(LKey.dataManagementImportFormatJsonl)),
                  Text(t(LKey.dataManagementImportFormatCsv)),
                  Text(t(LKey.dataManagementImportFormatXlsx)),
                  const SizedBox(height: 8),
                  Text(t(LKey.dataManagementImportFormatNote)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(HugeIcons.strokeRoundedFolder02),
              label: Text(
                _fileName == null
                    ? t(LKey.dataManagementImportButtonSelect)
                    : _fileName!,
              ),
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
            Text(t(LKey.dataManagementImportNote)),
          ],
        ),
      ),
    );
  }
}

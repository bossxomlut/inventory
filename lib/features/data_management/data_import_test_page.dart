import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../provider/theme.dart';
import '../../shared_widgets/index.dart';
import '../../services/data_import_service.dart';
import '../../services/data_import_service_ui.dart';

@RoutePage()
class DataImportTestPage extends ConsumerWidget {
  const DataImportTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Test giao diện nhập dữ liệu',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedInformationCircle,
                          color: theme.colorPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Test giao diện mới',
                          style: theme.headingSemibold20Default,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Thử nghiệm các giao diện thông báo mới cho quá trình nhập dữ liệu:',
                      style: theme.textRegular14Default,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildTestCard(
                    context,
                    'Test thành công hoàn toàn',
                    'Hiển thị kết quả import thành công 100%',
                    HugeIcons.strokeRoundedCheckmarkCircle02,
                    theme.colorTextSupportGreen,
                    () => _showSuccessfulImportDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildTestCard(
                    context,
                    'Test thành công một phần',
                    'Hiển thị kết quả import một phần có lỗi',
                    HugeIcons.strokeRoundedAlert02,
                    theme.colorTextSupportBlue,
                    () => _showPartialSuccessDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildTestCard(
                    context,
                    'Test thất bại hoàn toàn',
                    'Hiển thị kết quả import thất bại',
                    HugeIcons.strokeRoundedCancelCircle,
                    theme.colorError,
                    () => _showFailedImportDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildTestCard(
                    context,
                    'Test validation thành công',
                    'Hiển thị validation thành công',
                    HugeIcons.strokeRoundedCheckmarkCircle02,
                    theme.colorTextSupportGreen,
                    () => _showValidationSuccessDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildTestCard(
                    context,
                    'Test validation có cảnh báo',
                    'Hiển thị validation có warnings',
                    HugeIcons.strokeRoundedAlert02,
                    theme.colorTextSupportBlue,
                    () => _showValidationWarningDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildTestCard(
                    context,
                    'Test validation có lỗi',
                    'Hiển thị validation thất bại',
                    HugeIcons.strokeRoundedCancelCircle,
                    theme.colorError,
                    () => _showValidationErrorDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildTestCard(
                    context,
                    'Test import với validation',
                    'Test toàn bộ flow từ validation đến import',
                    HugeIcons.strokeRoundedFlow,
                    theme.colorPrimary,
                    () => _testFullImportFlow(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final theme = context.appTheme;

    return Card(
      color: Colors.white,
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.headingSemibold20Default,
        ),
        subtitle: Text(
          description,
          style: theme.textRegular14Default,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.colorPrimary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showSuccessfulImportDialog(BuildContext context) {
    final result = DataImportResult(
      success: true,
      totalLines: 10,
      successfulImports: 10,
      errors: [],
    );

    DataImportResultDialog.show(context, result, title: 'Test thành công hoàn toàn');
  }

  void _showPartialSuccessDialog(BuildContext context) {
    final result = DataImportResult(
      success: false,
      totalLines: 10,
      successfulImports: 7,
      errors: [
        'Lỗi khi nhập sản phẩm "Sản phẩm A": Mã vạch "12345" đã tồn tại trong cơ sở dữ liệu',
        'Lỗi phân tích dòng: {"name": "", "price": "invalid"}, Lỗi: Tên sản phẩm trống',
        'Lỗi khi nhập sản phẩm "Sản phẩm C": Exception: Không thể tạo category',
      ],
    );

    DataImportResultDialog.show(context, result, title: 'Test thành công một phần');
  }

  void _showFailedImportDialog(BuildContext context) {
    final result = DataImportResult(
      success: false,
      totalLines: 5,
      successfulImports: 0,
      errors: [
        'Không thể tải tệp dữ liệu: FileSystemException: Tệp không tồn tại',
        'Lỗi phân tích dòng: {invalid json}, Lỗi: FormatException: Unexpected character',
        'Lỗi khi nhập sản phẩm "Test Product": Exception: Database connection failed',
        'Lỗi phân tích dòng: {"name": null}, Lỗi: Null value not allowed',
        'Lỗi khi nhập sản phẩm "Another Product": Exception: Validation failed',
      ],
    );

    DataImportResultDialog.show(context, result, title: 'Test thất bại hoàn toàn');
  }

  void _showValidationSuccessDialog(BuildContext context) {
    final result = ValidationResult(
      isValid: true,
      totalLines: 5,
      validLines: 5,
      errors: [],
      warnings: [],
    );

    DataValidationResultDialog.show(
      context,
      result,
      title: 'Test validation thành công',
      onProceedImport: () {
        _showSuccessfulImportDialog(context);
      },
    );
  }

  void _showValidationWarningDialog(BuildContext context) {
    final result = ValidationResult(
      isValid: true,
      totalLines: 8,
      validLines: 8,
      errors: [],
      warnings: [
        'Dòng 2: Mã vạch "12345" đã tồn tại trong cơ sở dữ liệu',
        'Dòng 5: Tên sản phẩm bị thiếu hoặc trống',
        'Dòng 7: Định dạng giá không hợp lệ',
      ],
    );

    DataValidationResultDialog.show(
      context,
      result,
      title: 'Test validation có cảnh báo',
      onProceedImport: () {
        _showPartialSuccessDialog(context);
      },
    );
  }

  void _showValidationErrorDialog(BuildContext context) {
    final result = ValidationResult(
      isValid: false,
      totalLines: 6,
      validLines: 3,
      errors: [
        'Dòng 2: Mã vạch "ABC123" bị trùng lặp trong tệp nhập',
        'Dòng 4: Định dạng JSON không hợp lệ - FormatException: Unexpected end',
        'Dòng 6: Mã vạch "ABC123" bị trùng lặp trong tệp nhập',
      ],
      warnings: [
        'Dòng 1: Tên sản phẩm bị thiếu hoặc trống',
        'Dòng 3: Định dạng giá không hợp lệ',
      ],
    );

    DataValidationResultDialog.show(
      context,
      result,
      title: 'Test validation có lỗi',
    );
  }

  void _testFullImportFlow(BuildContext context, WidgetRef ref) {
    // Simulate a complete import flow with mock data
    const jsonlContent = '''
{"id": 1, "name": "Test Product 1", "categoryName": "Electronics", "unitName": "Piece", "price": 10000, "quantity": 50, "description": "A test product", "barcode": "TEST001"}
{"id": 2, "name": "Test Product 2", "categoryName": "Books", "unitName": "Piece", "price": 25000, "quantity": 30, "description": "Another test product", "barcode": "TEST002"}
{"id": 3, "name": "", "categoryName": "Food", "unitName": "Kg", "price": "invalid", "quantity": 100, "description": "Product with issues"}
{"id": 4, "name": "Test Product 4", "categoryName": "Electronics", "unitName": "Piece", "price": 15000, "quantity": 20, "barcode": "TEST001"}
    ''';

    final dataImportService = ref.read(dataImportServiceProvider);
    dataImportService.importFromJsonlStringWithValidation(
      context,
      jsonlContent,
      title: 'Test full import flow',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../domain/models/sample_product.dart';
import '../../../resources/index.dart';
import '../../../shared_widgets/index.dart';
import 'data_import_service.dart';

/// Extension methods for DataImportService to show UI dialogs
extension DataImportServiceUI on DataImportService {
  /// Import từ JSONL string với validation trước khi import
  Future<DataImportResult?> importFromJsonlStringWithValidation(
    BuildContext context,
    String jsonlContent, {
    String? title,
  }) async {
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);
    try {
      // Validate first
      final validation = await validateJsonlContent(jsonlContent);

      // Show validation result
      final shouldProceed = await DataValidationResultDialog.showValidation(
        context,
        validation,
        title: title ?? t(LKey.dataManagementImportValidationTitle),
      );

      if (!shouldProceed || !validation.isValid) {
        return null;
      }

      // Proceed with import
      final result = await importFromJsonlString(jsonlContent);

      // Show import result
      if (context.mounted) {
        await DataImportResultDialog.showResult(
          context,
          result,
          title: t(LKey.dataManagementImportResultTitle),
        );
      }

      return result;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LKey.commonErrorWithMessage.tr(
                context: context,
                namedArgs: {'error': '$e'},
              ),
            ),
          ),
        );
      }
      return null;
    }
  }

  /// Import từ asset file với validation
  Future<DataImportResult?> importFromAssetFileWithValidation(
    BuildContext context,
    String assetPath, {
    String? title,
  }) async {
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);
    try {
      // Load file content first for validation
      final stringData = await rootBundle.loadString(assetPath);
      return await importFromJsonlStringWithValidation(
        context,
        stringData,
        title: title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t(
                LKey.commonErrorWithMessage,
                namedArgs: {'error': '$e'},
              ),
            ),
          ),
        );
      }
      return null;
    }
  }

  /// Import từ list sản phẩm với hiển thị kết quả chi tiết
  Future<DataImportResult?> importFromSampleProductsWithUI(
    BuildContext context,
    List<SampleProduct> products, {
    String? title,
  }) async {
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);
    try {
      final result = await importFromSampleProducts(products);

      if (context.mounted) {
        await DataImportResultDialog.showResult(
          context,
          result,
          title: title ?? t(LKey.dataManagementImportResultTitle),
        );
      }

      return result;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LKey.commonErrorWithMessage.tr(
                context: context,
                namedArgs: {'error': '$e'},
              ),
            ),
          ),
        );
      }
      return null;
    }
  }
}

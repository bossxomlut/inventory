import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/index.dart';
import '../../../domain/entities/order/price.dart';
import '../../../domain/index.dart';
import '../../../domain/models/sample_product.dart';
import '../../../domain/repositories/order/price_repository.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../domain/repositories/product/update_product_repository.dart';
import 'drive_sync_types.dart';

/// Service for importing product data from JSONL files into the database
class DataImportService {
  final CategoryRepository categoryRepository;
  final UnitRepository unitRepository;
  final UpdateProductRepository updateProductRepository;
  final PriceRepository priceRepository;
  final SearchProductRepository searchProductRepository;

  DataImportService({
    required this.categoryRepository,
    required this.unitRepository,
    required this.updateProductRepository,
    required this.priceRepository,
    required this.searchProductRepository,
  });

  /// Import products from a JSONL file path
  Future<DataImportResult> importFromAssetFile(String assetPath) async {
    try {
      final stringData = await rootBundle.loadString(assetPath);
      return await importFromJsonlString(stringData);
    } catch (e) {
      return DataImportResult(
        success: false,
        totalLines: 0,
        successfulImports: 0,
        errors: ['Không thể tải tệp dữ liệu: $e'],
      );
    }
  }

  /// Import products from a list of SampleProduct objects
  Future<DataImportResult> importFromSampleProducts(List<SampleProduct> products) async {
    final List<String> errors = [];
    int successfulImports = 0;

    for (final product in products) {
      try {
        await _importSingleProduct(product.toJson());
        successfulImports++;
      } catch (e, st) {
        log('Lỗi khi nhập sản phẩm "${product.name}": $e', error: e, stackTrace: st);
        errors.add('Lỗi khi nhập sản phẩm "${product.name}": $e');
      }
    }

    return DataImportResult(
      success: errors.isEmpty,
      totalLines: products.length,
      successfulImports: successfulImports,
      errors: errors,
    );
  }

  /// Import products from an Excel (XLSX) file bytes
  Future<DataImportResult> importFromExcelBytes(Uint8List bytes) async {
    final List<String> errors = [];
    int successfulImports = 0;

    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        return DataImportResult(
          success: false,
          totalLines: 0,
          successfulImports: 0,
          errors: ['Không tìm thấy sheet nào trong file Excel.'],
        );
      }

      final sheet = excel.tables.values.first;
      if (sheet == null || sheet.rows.isEmpty) {
        return DataImportResult(
          success: false,
          totalLines: 0,
          successfulImports: 0,
          errors: ['Sheet Excel trống.'],
        );
      }

      final rows = sheet.rows;
      final headerMap = _buildHeaderMap(rows.first);
      if (headerMap.isEmpty) {
        return DataImportResult(
          success: false,
          totalLines: rows.length,
          successfulImports: 0,
          errors: ['Không tìm thấy header hợp lệ trong file Excel.'],
        );
      }

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        try {
          final name = _getCellString(row, headerMap, _excelHeaderName);
          final barcode = _getCellString(row, headerMap, _excelHeaderBarcode);
          final categoryName =
              _getCellString(row, headerMap, _excelHeaderCategory);
          final unitName = _getCellString(row, headerMap, _excelHeaderUnit);
          final description =
              _getCellString(row, headerMap, _excelHeaderDescription);
          final imageValues = _collectImageValuesFromRow(row, headerMap);
          final quantity =
              _getCellInt(row, headerMap, _excelHeaderQuantity, fallback: 0);
          final price = _getCellDouble(row, headerMap, _excelHeaderPrice);
          final enableExpiry =
              _getCellBool(row, headerMap, _excelHeaderExpiry);

          if (name.isEmpty) {
            // Skip empty rows
            if (barcode.isEmpty &&
                categoryName.isEmpty &&
                unitName.isEmpty &&
                description.isEmpty &&
                imageValues.isEmpty) {
              continue;
            }
            throw Exception('Thiếu tên sản phẩm');
          }

          final jsonData = <String, dynamic>{
            'id': undefinedId,
            'name': name,
            'quantity': quantity,
            'barcode': barcode.isEmpty ? null : barcode,
            'description': description.isEmpty ? null : description,
            'enableExpiryTracking': enableExpiry,
            if (categoryName.isNotEmpty) 'categoryName': categoryName,
            if (unitName.isNotEmpty) 'unitName': unitName,
            if (price != null) 'price': price,
            if (imageValues.isNotEmpty)
              'images': _buildImagesFromList(imageValues),
          };

          await _importSingleProduct(jsonData);
          successfulImports++;
        } catch (e) {
          errors.add('Dòng ${i + 1}: $e');
        }
      }
    } catch (e) {
      errors.add('Không thể đọc file Excel: $e');
    }

    return DataImportResult(
      success: errors.isEmpty,
      totalLines: successfulImports + errors.length,
      successfulImports: successfulImports,
      errors: errors,
    );
  }

  /// Import products from Google Sheets values
  Future<DataImportResult> importFromSheetValues(
    List<List<Object?>> rows, {
    DriveSyncCancellationToken? cancellation,
  }) async {
    final List<String> errors = [];
    int successfulImports = 0;

    cancellation?.throwIfCancelled();
    if (rows.isEmpty) {
      return DataImportResult(
        success: false,
        totalLines: 0,
        successfulImports: 0,
        errors: ['Sheet trống hoặc không có dữ liệu.'],
      );
    }

    final headerMap = _buildHeaderMapFromValues(rows.first);
    if (headerMap.isEmpty) {
      return DataImportResult(
        success: false,
        totalLines: rows.length,
        successfulImports: 0,
        errors: ['Không tìm thấy header hợp lệ trong sheet.'],
      );
    }

    for (int i = 1; i < rows.length; i++) {
      cancellation?.throwIfCancelled();
      final row = rows[i];
      try {
        final name = _getSheetString(row, headerMap, _excelHeaderName);
        final barcode = _getSheetString(row, headerMap, _excelHeaderBarcode);
        final categoryName =
            _getSheetString(row, headerMap, _excelHeaderCategory);
        final unitName = _getSheetString(row, headerMap, _excelHeaderUnit);
        final description =
            _getSheetString(row, headerMap, _excelHeaderDescription);
        final imageValues = _collectImageValuesFromSheetRow(row, headerMap);
        final quantity = _getSheetInt(
          row,
          headerMap,
          _excelHeaderQuantity,
          fallback: 0,
        );
        final price = _getSheetDouble(row, headerMap, _excelHeaderPrice);
        final enableExpiry = _getSheetBool(row, headerMap, _excelHeaderExpiry);

        if (name.isEmpty) {
          if (barcode.isEmpty &&
              categoryName.isEmpty &&
              unitName.isEmpty &&
              description.isEmpty &&
              imageValues.isEmpty) {
            continue;
          }
          throw Exception('Thiếu tên sản phẩm');
        }

        final jsonData = <String, dynamic>{
          'id': undefinedId,
          'name': name,
          'quantity': quantity,
          'barcode': barcode.isEmpty ? null : barcode,
          'description': description.isEmpty ? null : description,
          'enableExpiryTracking': enableExpiry,
          if (categoryName.isNotEmpty) 'categoryName': categoryName,
          if (unitName.isNotEmpty) 'unitName': unitName,
          if (price != null) 'price': price,
          if (imageValues.isNotEmpty)
            'images': _buildImagesFromList(imageValues),
        };

        await _importSingleProduct(jsonData);
        successfulImports++;
      } catch (e) {
        errors.add('Dòng ${i + 1}: $e');
      }
    }

    return DataImportResult(
      success: errors.isEmpty,
      totalLines: successfulImports + errors.length,
      successfulImports: successfulImports,
      errors: errors,
    );
  }

  /// Import products from an Excel (XLSX) file path
  Future<DataImportResult> importFromExcelFile(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      return importFromExcelBytes(bytes);
    } catch (e) {
      return DataImportResult(
        success: false,
        totalLines: 0,
        successfulImports: 0,
        errors: ['Không thể đọc file Excel: $e'],
      );
    }
  }

  /// Import products from JSONL string content
  Future<DataImportResult> importFromJsonlString(String jsonlContent) async {
    final List<String> errors = [];
    final lines = jsonlContent.split('\n').where((line) => line.trim().isNotEmpty).toList();

    int successfulImports = 0;

    for (final line in lines) {
      try {
        final jsonData = jsonDecode(line) as Map<String, dynamic>;
        await _importSingleProduct(jsonData);
        successfulImports++;
      } catch (e) {
        errors.add('Lỗi phân tích dòng: $line, Lỗi: $e');
      }
    }

    return DataImportResult(
      success: errors.isEmpty,
      totalLines: lines.length,
      successfulImports: successfulImports,
      errors: errors,
    );
  }

  /// Import a single product from JSON data
  Future<void> _importSingleProduct(Map<String, dynamic> jsonData) async {
    final String? categoryName = jsonData['categoryName'] as String?;
    final String? unitName = jsonData['unitName'] as String?;
    final String? barcode = jsonData['barcode'] as String?;

    // Check for barcode duplication if barcode exists
    if (barcode != null && barcode.isNotEmpty) {
      try {
        final existingProduct = await searchProductRepository.searchByBarcode(barcode);
        // If we reach here, a product with this barcode already exists
        throw Exception('Sản phẩm với mã vạch "$barcode" đã tồn tại: ${existingProduct.name}');
      } catch (e) {
        // If searchByBarcode throws "Product not found", that's what we want (barcode is unique)
        // Any other error should be rethrown
        if (!e.toString().contains('Product not found')) {
          rethrow;
        }
        // If "Product not found", continue with import - this is expected for new barcodes
      }
    }

    // Find or create category
    Category? category;
    if (categoryName != null && categoryName.isNotEmpty) {
      category = await categoryRepository.searchByName(categoryName);
      category ??= await categoryRepository.create(
        Category(id: undefinedId, name: categoryName),
      );
    }

    // Find or create unit
    Unit? unit;
    if (unitName != null && unitName.isNotEmpty) {
      unit = await unitRepository.searchByName(unitName);
      unit ??= await unitRepository.create(
        Unit(id: undefinedId, name: unitName),
      );
    }

    // Create product
    final product = Product.fromJson(jsonData);
    final createdProduct = await updateProductRepository.createProduct(
      product.copyWith(
        category: category,
        unit: unit,
      ),
    );

    // Create price if available
    final double? price = jsonData.parseDouble('price');
    if (price != null && price > 0) {
      await priceRepository.create(
        ProductPrice(
          id: undefinedId,
          productId: createdProduct.id,
          productName: createdProduct.name,
          sellingPrice: price,
        ),
      );
    }
  }

  /// Validate JSONL content before importing
  Future<ValidationResult> validateJsonlContent(String jsonlContent) async {
    final List<String> errors = [];
    final List<String> warnings = [];
    final lines = jsonlContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final Set<String> seenBarcodes = <String>{};

    int validLines = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      try {
        final jsonData = jsonDecode(line) as Map<String, dynamic>;

        // Check required fields
        if (jsonData['name'] == null || (jsonData['name'] as String).isEmpty) {
          warnings.add('Dòng ${i + 1}: Tên sản phẩm bị thiếu hoặc trống');
        }

        // Check price format
        final price = jsonData['price'];
        if (price != null && price is! num && double.tryParse(price.toString()) == null) {
          warnings.add('Dòng ${i + 1}: Định dạng giá không hợp lệ');
        }

        // Check barcode duplication within the file
        final String? barcode = jsonData['barcode'] as String?;
        if (barcode != null && barcode.isNotEmpty) {
          if (seenBarcodes.contains(barcode)) {
            errors.add('Dòng ${i + 1}: Mã vạch "$barcode" bị trùng lặp trong tệp nhập');
          } else {
            seenBarcodes.add(barcode);

            // Check if barcode already exists in database
            try {
              await searchProductRepository.searchByBarcode(barcode);
              // If we reach here, product with this barcode exists
              warnings.add('Dòng ${i + 1}: Mã vạch "$barcode" đã tồn tại trong cơ sở dữ liệu');
            } catch (e) {
              // If "Product not found", that's good - barcode is unique
              if (!e.toString().contains('Product not found')) {
                warnings.add('Dòng ${i + 1}: Không thể xác minh tính duy nhất của mã vạch "$barcode": $e');
              }
            }
          }
        }

        validLines++;
      } catch (e) {
        errors.add('Dòng ${i + 1}: Định dạng JSON không hợp lệ - $e');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      totalLines: lines.length,
      validLines: validLines,
      errors: errors,
      warnings: warnings,
    );
  }

  static const List<String> _excelHeaderName = <String>[
    'tên sản phẩm',
    'name',
  ];
  static const List<String> _excelHeaderQuantity = <String>[
    'số lượng',
    'quantity',
  ];
  static const List<String> _excelHeaderBarcode = <String>[
    'mã vạch',
    'barcode',
  ];
  static const List<String> _excelHeaderCategory = <String>[
    'danh mục',
    'category',
    'categoryname',
  ];
  static const List<String> _excelHeaderUnit = <String>[
    'đơn vị',
    'unit',
    'unitname',
  ];
  static const List<String> _excelHeaderDescription = <String>[
    'mô tả',
    'description',
  ];
  static const List<String> _excelHeaderImage = <String>[
    'ảnh',
    'image',
    'images',
  ];
  static const List<String> _excelHeaderPrice = <String>[
    'giá',
    'price',
  ];
  static const List<String> _excelHeaderExpiry = <String>[
    'theo dõi hạn',
    'expiry',
    'enableexpirytracking',
  ];

  Map<String, int> _buildHeaderMap(List<Data?> headerRow) {
    final Map<String, int> map = <String, int>{};
    for (int i = 0; i < headerRow.length; i++) {
      final cellValue = headerRow[i]?.value;
      if (cellValue == null) {
        continue;
      }
      final key = _normalizeHeader(_cellToString(cellValue));
      if (key.isNotEmpty) {
        map[key] = i;
      }
    }
    return map;
  }

  Map<String, int> _buildHeaderMapFromValues(List<Object?> headerRow) {
    final Map<String, int> map = <String, int>{};
    for (int i = 0; i < headerRow.length; i++) {
      final cellValue = headerRow[i];
      if (cellValue == null) {
        continue;
      }
      final key = _normalizeHeader(_sheetValueToString(cellValue));
      if (key.isNotEmpty) {
        map[key] = i;
      }
    }
    return map;
  }

  String _normalizeHeader(String input) {
    return input.trim().toLowerCase();
  }

  bool _isImageHeader(String normalized) {
    if (_excelHeaderImage.contains(normalized)) {
      return true;
    }
    return normalized.startsWith('ảnh') || normalized.startsWith('image');
  }

  List<String> _collectImageValuesFromRow(
    List<Data?> row,
    Map<String, int> headers,
  ) {
    final entries = headers.entries
        .where((entry) => _isImageHeader(entry.key))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final values = <String>[];
    for (final entry in entries) {
      if (entry.value >= row.length) {
        continue;
      }
      final raw = _cellToString(row[entry.value]?.value);
      final normalized = raw.trim();
      if (normalized.isEmpty || _isImageFormula(normalized)) {
        continue;
      }
      values.add(normalized);
    }
    return values;
  }

  List<String> _collectImageValuesFromSheetRow(
    List<Object?> row,
    Map<String, int> headers,
  ) {
    final entries = headers.entries
        .where((entry) => _isImageHeader(entry.key))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final values = <String>[];
    for (final entry in entries) {
      if (entry.value >= row.length) {
        continue;
      }
      final raw = _sheetValueToString(row[entry.value]);
      final normalized = raw.trim();
      if (normalized.isEmpty || _isImageFormula(normalized)) {
        continue;
      }
      values.add(normalized);
    }
    return values;
  }

  bool _isImageFormula(String value) {
    return value.trim().toUpperCase().startsWith('=IMAGE(');
  }

  String _getCellString(
    List<Data?> row,
    Map<String, int> headers,
    List<String> keys,
  ) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return '';
    }
    final value = row[index]?.value;
    return _cellToString(value);
  }

  String _getSheetString(
    List<Object?> row,
    Map<String, int> headers,
    List<String> keys,
  ) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return '';
    }
    return _sheetValueToString(row[index]);
  }

  int _getCellInt(
    List<Data?> row,
    Map<String, int> headers,
    List<String> keys, {
    int fallback = 0,
  }) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return fallback;
    }
    return _cellToInt(row[index]?.value, fallback);
  }

  int _getSheetInt(
    List<Object?> row,
    Map<String, int> headers,
    List<String> keys, {
    int fallback = 0,
  }) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return fallback;
    }
    return _sheetValueToInt(row[index], fallback);
  }

  double? _getCellDouble(
    List<Data?> row,
    Map<String, int> headers,
    List<String> keys,
  ) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return null;
    }
    return _cellToDouble(row[index]?.value);
  }

  double? _getSheetDouble(
    List<Object?> row,
    Map<String, int> headers,
    List<String> keys,
  ) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return null;
    }
    return _sheetValueToDouble(row[index]);
  }

  bool _getCellBool(
    List<Data?> row,
    Map<String, int> headers,
    List<String> keys,
  ) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return false;
    }
    return _cellToBool(row[index]?.value);
  }

  bool _getSheetBool(
    List<Object?> row,
    Map<String, int> headers,
    List<String> keys,
  ) {
    final index = _findHeaderIndex(headers, keys);
    if (index == null || index >= row.length) {
      return false;
    }
    return _sheetValueToBool(row[index]);
  }

  int? _findHeaderIndex(Map<String, int> headers, List<String> keys) {
    for (final key in keys) {
      final index = headers[_normalizeHeader(key)];
      if (index != null) {
        return index;
      }
    }
    return null;
  }

  String _cellToString(CellValue? value) {
    if (value == null) {
      return '';
    }
    if (value is TextCellValue) {
      return _textSpanToPlainText(value.value).trim();
    }
    if (value is IntCellValue) {
      return value.value.toString();
    }
    if (value is DoubleCellValue) {
      return value.value.toString();
    }
    if (value is BoolCellValue) {
      return value.value.toString();
    }
    if (value is DateCellValue) {
      return value.asDateTimeLocal().toIso8601String();
    }
    if (value is DateTimeCellValue) {
      return value.asDateTimeLocal().toIso8601String();
    }
    if (value is TimeCellValue) {
      return value.asDuration().toString();
    }
    if (value is FormulaCellValue) {
      return value.formula;
    }
    return value.toString();
  }

  String _sheetValueToString(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }

  int _cellToInt(CellValue? value, int fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is IntCellValue) {
      return value.value;
    }
    if (value is DoubleCellValue) {
      return value.value.round();
    }
    if (value is BoolCellValue) {
      return value.value ? 1 : 0;
    }
    if (value is TextCellValue) {
      final text = _textSpanToPlainText(value.value).trim();
      return int.tryParse(text) ?? fallback;
    }
    return fallback;
  }

  int _sheetValueToInt(Object? value, int fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is num) {
      return value.round();
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is String) {
      final text = value.trim();
      return int.tryParse(text) ?? fallback;
    }
    return fallback;
  }

  double? _cellToDouble(CellValue? value) {
    if (value == null) {
      return null;
    }
    if (value is DoubleCellValue) {
      return value.value;
    }
    if (value is IntCellValue) {
      return value.value.toDouble();
    }
    if (value is BoolCellValue) {
      return value.value ? 1.0 : 0.0;
    }
    if (value is TextCellValue) {
      final text = _textSpanToPlainText(value.value).trim();
      return double.tryParse(text.replaceAll(',', '.'));
    }
    return null;
  }

  double? _sheetValueToDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is bool) {
      return value ? 1.0 : 0.0;
    }
    if (value is String) {
      final text = value.trim();
      return double.tryParse(text.replaceAll(',', '.'));
    }
    return null;
  }

  bool _cellToBool(CellValue? value) {
    if (value == null) {
      return false;
    }
    if (value is BoolCellValue) {
      return value.value;
    }
    if (value is IntCellValue) {
      return value.value != 0;
    }
    if (value is DoubleCellValue) {
      return value.value != 0;
    }
    if (value is TextCellValue) {
      final normalized = _textSpanToPlainText(value.value).trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  bool _sheetValueToBool(Object? value) {
    if (value == null) {
      return false;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  List<Map<String, dynamic>> _buildImagesFromList(List<String> values) {
    final paths = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || _isImageFormula(trimmed)) {
        continue;
      }
      paths.addAll(
        trimmed
            .split(RegExp(r'[;,\n]+'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      );
    }
    if (paths.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    return paths
        .map((path) => <String, dynamic>{'id': undefinedId, 'path': path})
        .toList();
  }

  String _textSpanToPlainText(TextSpan span) {
    final buffer = StringBuffer();
    if (span.text != null) {
      buffer.write(span.text);
    }
    final children = span.children;
    if (children != null) {
      for (final child in children) {
        buffer.write(_textSpanToPlainText(child));
      }
    }
    return buffer.toString();
  }
}

/// Result of data import operation
class DataImportResult {
  final bool success;
  final int totalLines;
  final int successfulImports;
  final List<String> errors;

  DataImportResult({
    required this.success,
    required this.totalLines,
    required this.successfulImports,
    required this.errors,
  });

  int get failedImports => totalLines - successfulImports;
  bool get hasErrors => errors.isNotEmpty;
  bool get hasPartialSuccess => successfulImports > 0 && failedImports > 0;
}

/// Result of validation operation
class ValidationResult {
  final bool isValid;
  final int totalLines;
  final int validLines;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.totalLines,
    required this.validLines,
    required this.errors,
    required this.warnings,
  });

  int get invalidLines => totalLines - validLines;
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Provider for DataImportService
final dataImportServiceProvider = Provider<DataImportService>((ref) {
  return DataImportService(
    categoryRepository: ref.read(categoryRepositoryProvider),
    unitRepository: ref.read(unitRepositoryProvider),
    updateProductRepository: ref.read(updateProductRepositoryProvider),
    priceRepository: ref.read(priceRepositoryProvider),
    searchProductRepository: ref.read(searchProductRepositoryProvider),
  );
});

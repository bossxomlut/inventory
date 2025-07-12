import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/index.dart';
import '../domain/entities/order/price.dart';
import '../domain/index.dart';
import '../domain/repositories/product/inventory_repository.dart';
import '../domain/repositories/order/price_repository.dart';
import '../domain/repositories/product/update_product_repository.dart';
import '../domain/models/sample_product.dart';

/// Service for importing product data from JSONL files into the database
class DataImportService {
  final CategoryRepository categoryRepository;
  final UnitRepository unitRepository;
  final UpdateProductRepository updateProductRepository;
  final PriceRepository priceRepository;

  DataImportService({
    required this.categoryRepository,
    required this.unitRepository,
    required this.updateProductRepository,
    required this.priceRepository,
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
        errors: ['Failed to load asset file: $e'],
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
      } catch (e) {
        errors.add('Error importing product ${product.name}: $e');
      }
    }

    return DataImportResult(
      success: errors.isEmpty,
      totalLines: products.length,
      successfulImports: successfulImports,
      errors: errors,
    );
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
        errors.add('Error parsing line: $line, Error: $e');
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

    int validLines = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      try {
        final jsonData = jsonDecode(line) as Map<String, dynamic>;

        // Check required fields
        if (jsonData['name'] == null || (jsonData['name'] as String).isEmpty) {
          warnings.add('Line ${i + 1}: Product name is missing or empty');
        }

        // Check price format
        final price = jsonData['price'];
        if (price != null && price is! num && double.tryParse(price.toString()) == null) {
          warnings.add('Line ${i + 1}: Invalid price format');
        }

        validLines++;
      } catch (e) {
        errors.add('Line ${i + 1}: Invalid JSON format - $e');
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
  );
});

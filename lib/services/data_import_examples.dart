// Example usage of DataImportService

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/data_import_service.dart';
import '../domain/models/sample_product.dart';

class DataImportExamples {
  /// Example 1: Import data from asset JSONL file
  static Future<void> importFromAssetExample(WidgetRef ref) async {
    final dataImportService = ref.read(dataImportServiceProvider);

    // Import from any JSONL file in assets
    final result = await dataImportService.importFromAssetFile('assets/data/mock.jsonl');

    if (result.success) {
      print('✅ Successfully imported ${result.successfulImports} products');
    } else {
      print('❌ Import failed or partially failed:');
      print('   - Successful: ${result.successfulImports}');
      print('   - Failed: ${result.failedImports}');
      print('   - Errors: ${result.errors.join(", ")}');
    }
  }

  /// Example 2: Import specific shop type data
  static Future<void> importShopTypeDataExample(WidgetRef ref, String shopTypeAssetPath) async {
    final dataImportService = ref.read(dataImportServiceProvider);

    // Import from shop type specific JSONL file
    final result = await dataImportService.importFromAssetFile(shopTypeAssetPath);

    print('Import result for shop type:');
    print('- Total products: ${result.totalLines}');
    print('- Successfully imported: ${result.successfulImports}');
    print('- Failed imports: ${result.failedImports}');

    if (result.hasErrors) {
      print('- Errors:');
      for (final error in result.errors) {
        print('  * $error');
      }
    }
  }

  /// Example 3: Import from list of SampleProduct objects
  static Future<void> importSelectedProductsExample(WidgetRef ref, List<SampleProduct> selectedProducts) async {
    final dataImportService = ref.read(dataImportServiceProvider);

    // Import selected products
    final result = await dataImportService.importFromSampleProducts(selectedProducts);

    if (result.success) {
      print('✅ All ${selectedProducts.length} selected products imported successfully');
    } else if (result.hasPartialSuccess) {
      print('⚠️ Partial success: ${result.successfulImports}/${selectedProducts.length} products imported');
    } else {
      print('❌ Import failed completely');
    }
  }

  /// Example 4: Validate JSONL content before importing
  static Future<void> validateBeforeImportExample(WidgetRef ref, String jsonlContent) async {
    final dataImportService = ref.read(dataImportServiceProvider);

    // Validate first
    final validation = await dataImportService.validateJsonlContent(jsonlContent);

    if (validation.isValid) {
      print('✅ Content is valid, proceeding with import...');
      final result = await dataImportService.importFromJsonlString(jsonlContent);
      print('Import completed: ${result.successfulImports} products imported');
    } else {
      print('❌ Content validation failed:');
      print('- Total lines: ${validation.totalLines}');
      print('- Valid lines: ${validation.validLines}');
      print('- Invalid lines: ${validation.invalidLines}');

      if (validation.errors.isNotEmpty) {
        print('- Errors:');
        for (final error in validation.errors) {
          print('  * $error');
        }
      }

      if (validation.hasWarnings) {
        print('- Warnings:');
        for (final warning in validation.warnings) {
          print('  * $warning');
        }
      }
    }
  }

  /// Example 5: Import with custom JSONL string content
  static Future<void> importFromStringExample(WidgetRef ref) async {
    final dataImportService = ref.read(dataImportServiceProvider);

    // Custom JSONL content
    const jsonlContent = '''
{"id": 1, "name": "Sample Product 1", "categoryName": "Electronics", "unitName": "Piece", "price": 10000, "quantity": 50, "description": "A sample electronic product", "barcode": "123456789"}
{"id": 2, "name": "Sample Product 2", "categoryName": "Books", "unitName": "Piece", "price": 25000, "quantity": 30, "description": "A sample book", "barcode": "987654321"}
{"id": 3, "name": "Sample Product 3", "categoryName": "Food", "unitName": "Kg", "price": 15000, "quantity": 100, "description": "A sample food item"}
    ''';

    final result = await dataImportService.importFromJsonlString(jsonlContent);

    print('Custom import result:');
    print('- Products processed: ${result.totalLines}');
    print('- Successfully imported: ${result.successfulImports}');
    print('- Errors: ${result.errors.length}');
  }
}

/*
Usage in your app:

1. In guest login (auth_provider.dart):
   - Already implemented using importFromAssetFile('assets/data/mock.jsonl')

2. In product selection page (product_selection_page.dart):
   - Already implemented using importFromSampleProducts(selectedProducts)

3. For importing shop type data:
   ```dart
   await DataImportExamples.importShopTypeDataExample(ref, 'assets/data/shop_types/grocery_store.jsonl');
   ```

4. For custom data import:
   ```dart
   final customProducts = [
     SampleProduct(id: 1, name: 'Custom Product', categoryName: 'Custom', unitName: 'Piece', price: 5000, quantity: 10),
     // ... more products
   ];
   await DataImportExamples.importSelectedProductsExample(ref, customProducts);
   ```
*/

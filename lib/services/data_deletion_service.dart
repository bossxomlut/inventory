import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/repositories/product/inventory_repository.dart';

/// Service for managing data deletion operations
class DataDeletionService {
  final Ref ref;

  DataDeletionService({required this.ref});

  /// Delete all products from the database
  Future<DataDeletionResult> deleteAllProducts() async {
    try {
      log('Bắt đầu xóa tất cả sản phẩm...');

      final productRepo = ref.read(productRepositoryProvider);

      // Get all products first to count them
      final allProductsResult = await productRepo.search('', 1, 10000);
      final allProducts = allProductsResult.data;

      if (allProducts.isEmpty) {
        return DataDeletionResult(
          success: true,
          totalItems: 0,
          deletedCount: 0,
          failedCount: 0,
          errors: [],
          message: 'Không có sản phẩm nào để xóa',
        );
      }

      final List<String> errors = [];
      int deletedCount = 0;
      int totalItems = allProducts.length;

      // Delete each product individually
      for (final product in allProducts) {
        try {
          final success = await productRepo.delete(product);
          if (success) {
            deletedCount++;
          } else {
            errors.add('Không thể xóa sản phẩm: ${product.name}');
          }
        } catch (e) {
          errors.add('Lỗi khi xóa sản phẩm ${product.name}: $e');
        }
      }

      final bool overallSuccess = deletedCount > 0;
      final String message = overallSuccess ? 'Đã xóa $deletedCount/$totalItems sản phẩm' : 'Không thể xóa sản phẩm nào';

      log('Hoàn thành xóa sản phẩm: $deletedCount/$totalItems');

      return DataDeletionResult(
        success: overallSuccess,
        totalItems: totalItems,
        deletedCount: deletedCount,
        failedCount: totalItems - deletedCount,
        errors: errors,
        message: message,
      );
    } catch (e) {
      log('Lỗi khi xóa tất cả sản phẩm: $e');
      return DataDeletionResult(
        success: false,
        totalItems: 0,
        deletedCount: 0,
        failedCount: 0,
        errors: ['Lỗi khi xóa sản phẩm: $e'],
        message: 'Lỗi khi xóa sản phẩm',
      );
    }
  }

  /// Delete all categories from the database
  Future<DataDeletionResult> deleteAllCategories() async {
    try {
      log('Bắt đầu xóa tất cả danh mục...');

      final categoryRepo = ref.read(categoryRepositoryProvider);

      // Get all categories first
      final allCategories = await categoryRepo.getAll();

      if (allCategories.isEmpty) {
        return DataDeletionResult(
          success: true,
          totalItems: 0,
          deletedCount: 0,
          failedCount: 0,
          errors: [],
          message: 'Không có danh mục nào để xóa',
        );
      }

      final List<String> errors = [];
      int deletedCount = 0;
      int totalItems = allCategories.length;

      // Delete each category individually
      for (final category in allCategories) {
        try {
          final success = await categoryRepo.delete(category);
          if (success) {
            deletedCount++;
          } else {
            errors.add('Không thể xóa danh mục: ${category.name}');
          }
        } catch (e) {
          errors.add('Lỗi khi xóa danh mục ${category.name}: $e');
        }
      }

      final bool overallSuccess = deletedCount > 0;
      final String message = overallSuccess ? 'Đã xóa $deletedCount/$totalItems danh mục' : 'Không thể xóa danh mục nào';

      log('Hoàn thành xóa danh mục: $deletedCount/$totalItems');

      return DataDeletionResult(
        success: overallSuccess,
        totalItems: totalItems,
        deletedCount: deletedCount,
        failedCount: totalItems - deletedCount,
        errors: errors,
        message: message,
      );
    } catch (e) {
      log('Lỗi khi xóa tất cả danh mục: $e');
      return DataDeletionResult(
        success: false,
        totalItems: 0,
        deletedCount: 0,
        failedCount: 0,
        errors: ['Lỗi khi xóa danh mục: $e'],
        message: 'Lỗi khi xóa danh mục',
      );
    }
  }

  /// Delete all units from the database
  Future<DataDeletionResult> deleteAllUnits() async {
    try {
      log('Bắt đầu xóa tất cả đơn vị...');

      final unitRepo = ref.read(unitRepositoryProvider);

      // Get all units first
      final allUnits = await unitRepo.getAll();

      if (allUnits.isEmpty) {
        return DataDeletionResult(
          success: true,
          totalItems: 0,
          deletedCount: 0,
          failedCount: 0,
          errors: [],
          message: 'Không có đơn vị nào để xóa',
        );
      }

      final List<String> errors = [];
      int deletedCount = 0;
      int totalItems = allUnits.length;

      // Delete each unit individually
      for (final unit in allUnits) {
        try {
          final success = await unitRepo.delete(unit);
          if (success) {
            deletedCount++;
          } else {
            errors.add('Không thể xóa đơn vị: ${unit.name}');
          }
        } catch (e) {
          errors.add('Lỗi khi xóa đơn vị ${unit.name}: $e');
        }
      }

      final bool overallSuccess = deletedCount > 0;
      final String message = overallSuccess ? 'Đã xóa $deletedCount/$totalItems đơn vị' : 'Không thể xóa đơn vị nào';

      log('Hoàn thành xóa đơn vị: $deletedCount/$totalItems');

      return DataDeletionResult(
        success: overallSuccess,
        totalItems: totalItems,
        deletedCount: deletedCount,
        failedCount: totalItems - deletedCount,
        errors: errors,
        message: message,
      );
    } catch (e) {
      log('Lỗi khi xóa tất cả đơn vị: $e');
      return DataDeletionResult(
        success: false,
        totalItems: 0,
        deletedCount: 0,
        failedCount: 0,
        errors: ['Lỗi khi xóa đơn vị: $e'],
        message: 'Lỗi khi xóa đơn vị',
      );
    }
  }

  /// Delete all data (products, categories, and units) from the database
  Future<DataDeletionResult> deleteAllData() async {
    try {
      log('Bắt đầu xóa tất cả dữ liệu...');

      final List<String> allErrors = [];
      int totalDeletedCount = 0;
      int totalFailedCount = 0;
      int totalItemsCount = 0;

      // Delete products first (they depend on categories and units)
      final productResult = await deleteAllProducts();
      allErrors.addAll(productResult.errors);
      totalDeletedCount += productResult.deletedCount;
      totalFailedCount += productResult.failedCount;
      totalItemsCount += productResult.totalItems;

      // Then delete categories
      final categoryResult = await deleteAllCategories();
      allErrors.addAll(categoryResult.errors);
      totalDeletedCount += categoryResult.deletedCount;
      totalFailedCount += categoryResult.failedCount;
      totalItemsCount += categoryResult.totalItems;

      // Finally delete units
      final unitResult = await deleteAllUnits();
      allErrors.addAll(unitResult.errors);
      totalDeletedCount += unitResult.deletedCount;
      totalFailedCount += unitResult.failedCount;
      totalItemsCount += unitResult.totalItems;

      final bool overallSuccess = totalDeletedCount > 0;
      final String message = overallSuccess ? 'Đã xóa $totalDeletedCount/$totalItemsCount mục dữ liệu' : 'Không thể xóa dữ liệu nào';

      log('Hoàn thành xóa tất cả dữ liệu: $totalDeletedCount/$totalItemsCount');

      return DataDeletionResult(
        success: overallSuccess,
        totalItems: totalItemsCount,
        deletedCount: totalDeletedCount,
        failedCount: totalFailedCount,
        errors: allErrors,
        message: message,
      );
    } catch (e) {
      log('Lỗi khi xóa tất cả dữ liệu: $e');
      return DataDeletionResult(
        success: false,
        totalItems: 0,
        deletedCount: 0,
        failedCount: 0,
        errors: ['Lỗi khi xóa tất cả dữ liệu: $e'],
        message: 'Lỗi khi xóa tất cả dữ liệu',
      );
    }
  }
}

/// Result of a deletion operation
class DataDeletionResult {
  final bool success;
  final int totalItems;
  final int deletedCount;
  final int failedCount;
  final List<String> errors;
  final String message;

  const DataDeletionResult({
    required this.success,
    required this.totalItems,
    required this.deletedCount,
    required this.failedCount,
    required this.errors,
    required this.message,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasPartialSuccess => deletedCount > 0 && failedCount > 0;
}

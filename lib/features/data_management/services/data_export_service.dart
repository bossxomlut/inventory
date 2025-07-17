import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../domain/repositories/order/order_repository.dart';
import '../../../provider/load_list.dart';

/// Service for exporting application data to different formats
///
/// Format differences:
/// - JSONL: Export full object with complete information (developer-friendly)
/// - CSV: Export simplified data with human-readable names only (user-friendly)
class DataExportService {
  final Ref ref;

  // Static variable để track xem đã hỏi quyền chưa trong session này
  static bool _hasRequestedPermission = false;

  DataExportService(this.ref);

  /// Export products to JSONL format (full object data for developers)
  Future<String> exportProductsToJsonl() async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final result = await productRepo.search('', 1, 10000); // Get all products

      final jsonlData = result.data.map((product) => jsonEncode(product.toJson())).join('\n');

      final file = await _saveToFile('products_${_getTimestamp()}.jsonl', jsonlData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu sản phẩm: $e');
    }
  }

  /// Export products to CSV format (simple data with names only for users)
  Future<String> exportProductsToCsv() async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final result = await productRepo.search('', 1, 10000); // Get all products

      final csvData = _convertProductsToCsv(result.data);

      final file = await _saveToFile('products_${_getTimestamp()}.csv', csvData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu sản phẩm: $e');
    }
  }

  /// Export categories to JSONL format (full object data)
  Future<String> exportCategoriesToJsonl() async {
    try {
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final result = await categoryRepo.search('', 1, 10000); // Get all categories

      final jsonlData = result.data.map((category) => jsonEncode(category.toJson())).join('\n');

      final file = await _saveToFile('categories_${_getTimestamp()}.jsonl', jsonlData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu danh mục: $e');
    }
  }

  /// Export categories to CSV format (simple data)
  Future<String> exportCategoriesToCsv() async {
    try {
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final result = await categoryRepo.search('', 1, 10000); // Get all categories

      final csvData = _convertCategoriesToCsv(result.data);

      final file = await _saveToFile('categories_${_getTimestamp()}.csv', csvData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu danh mục: $e');
    }
  }

  /// Export units to JSONL format (full object data)
  Future<String> exportUnitsToJsonl() async {
    try {
      final unitRepo = ref.read(unitRepositoryProvider);
      final result = await unitRepo.search('', 1, 10000); // Get all units

      final jsonlData = result.data.map((unit) => jsonEncode(unit.toJson())).join('\n');

      final file = await _saveToFile('units_${_getTimestamp()}.jsonl', jsonlData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu đơn vị: $e');
    }
  }

  /// Export units to CSV format (simple data)
  Future<String> exportUnitsToCsv() async {
    try {
      final unitRepo = ref.read(unitRepositoryProvider);
      final result = await unitRepo.search('', 1, 10000); // Get all units

      final csvData = _convertUnitsToCsv(result.data);

      final file = await _saveToFile('units_${_getTimestamp()}.csv', csvData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu đơn vị: $e');
    }
  }

  /// Export orders to JSONL format (full object data)
  Future<String> exportOrdersToJsonl() async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);

      // Get orders from all statuses
      final List<Order> allOrders = <Order>[];
      for (final status in OrderStatus.values) {
        final result = await orderRepo.getOrdersByStatus(status, const LoadListQuery(page: 1, pageSize: 10000));
        allOrders.addAll(result.data);
      }

      final jsonlData = allOrders
          .map((Order order) => jsonEncode({
                'id': order.id,
                'status': order.status.name,
                'orderDate': order.orderDate.toIso8601String(),
                'createdAt': order.createdAt.toIso8601String(),
                'createdBy': order.createdBy,
                'productCount': order.productCount,
                'totalAmount': order.totalAmount,
                'totalPrice': order.totalPrice,
                'updatedAt': order.updatedAt?.toIso8601String(),
                'customer': order.customer,
                'customerContact': order.customerContact,
                'note': order.note,
                'discount': order.discount,
              }))
          .join('\n');

      final file = await _saveToFile('orders_${_getTimestamp()}.jsonl', jsonlData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu đơn hàng: $e');
    }
  }

  /// Export orders to CSV format (simple data)
  Future<String> exportOrdersToCsv() async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);

      // Get orders from all statuses
      final List<Order> allOrders = <Order>[];
      for (final status in OrderStatus.values) {
        final result = await orderRepo.getOrdersByStatus(status, const LoadListQuery(page: 1, pageSize: 10000));
        allOrders.addAll(result.data);
      }

      final csvData = _convertOrdersToCsv(allOrders);

      final file = await _saveToFile('orders_${_getTimestamp()}.csv', csvData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu đơn hàng: $e');
    }
  }

  /// Create a full backup of all data
  Future<String> createFullBackup() async {
    try {
      final Map<String, dynamic> backupData = <String, dynamic>{
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'data': <String, List<Map<String, dynamic>>>{
          'products': <Map<String, dynamic>>[],
          'categories': <Map<String, dynamic>>[],
          'units': <Map<String, dynamic>>[],
          'orders': <Map<String, dynamic>>[],
        }
      };

      // Fetch all data
      final productRepo = ref.read(productRepositoryProvider);
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final unitRepo = ref.read(unitRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);

      final productResult = await productRepo.search('', 1, 10000);
      final categoryResult = await categoryRepo.search('', 1, 10000);
      final unitResult = await unitRepo.search('', 1, 10000);

      // Get orders from all statuses
      final List<Order> allOrders = <Order>[];
      for (final status in OrderStatus.values) {
        final result = await orderRepo.getOrdersByStatus(status, const LoadListQuery(page: 1, pageSize: 10000));
        allOrders.addAll(result.data);
      }

      final data = backupData['data'] as Map<String, List<Map<String, dynamic>>>;
      data['products'] = productResult.data.map((p) => p.toJson()).toList();
      data['categories'] = categoryResult.data.map((c) => c.toJson()).toList();
      data['units'] = unitResult.data.map((u) => u.toJson()).toList();
      data['orders'] = allOrders
          .map((Order o) => <String, dynamic>{
                'id': o.id,
                'status': o.status.name,
                'orderDate': o.orderDate.toIso8601String(),
                'createdAt': o.createdAt.toIso8601String(),
                'createdBy': o.createdBy,
                'productCount': o.productCount,
                'totalAmount': o.totalAmount,
                'totalPrice': o.totalPrice,
                'updatedAt': o.updatedAt?.toIso8601String(),
                'customer': o.customer,
                'customerContact': o.customerContact,
                'note': o.note,
                'discount': o.discount,
              })
          .toList();

      final jsonContent = const JsonEncoder.withIndent('  ').convert(backupData);
      final file = await _saveToFile('inventory_backup_${_getTimestamp()}.json', jsonContent);
      return file.path;
    } catch (e) {
      throw Exception('Không thể tạo file backup: $e');
    }
  }

  /// Share exported file
  Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      throw Exception('Không thể chia sẻ file: $e');
    }
  }

  // Private helper methods
  String _convertProductsToCsv(List<Product> products) {
    // CSV format chỉ export tên danh mục và tên đơn vị (user-friendly)
    final header = 'ID,Tên sản phẩm,Số lượng,Mã vạch,Danh mục,Đơn vị,Mô tả\n';
    final rows = products.map((product) {
      return [
        product.id.toString(),
        _escapeCsvField(product.name),
        product.quantity.toString(),
        _escapeCsvField(product.barcode ?? ''),
        _escapeCsvField(product.category?.name ?? 'Chưa phân loại'), // Chỉ export tên danh mục
        _escapeCsvField(product.unit?.name ?? 'Chưa có đơn vị'), // Chỉ export tên đơn vị
        _escapeCsvField(product.description ?? ''),
      ].join(',');
    }).join('\n');

    return header + rows;
  }

  String _convertCategoriesToCsv(List<Category> categories) {
    // CSV format đơn giản cho danh mục (user-friendly)
    final header = 'ID,Tên danh mục,Mô tả,Ngày tạo,Ngày cập nhật\n';
    final rows = categories.map((category) {
      return [
        category.id.toString(),
        _escapeCsvField(category.name),
        _escapeCsvField(category.description ?? ''),
        category.createDate?.toIso8601String() ?? '',
        category.updatedDate?.toIso8601String() ?? '',
      ].join(',');
    }).join('\n');

    return header + rows;
  }

  String _convertUnitsToCsv(List<Unit> units) {
    // CSV format đơn giản cho đơn vị (user-friendly)
    final header = 'ID,Tên đơn vị,Mô tả,Ngày tạo,Ngày cập nhật\n';
    final rows = units.map((unit) {
      return [
        unit.id.toString(),
        _escapeCsvField(unit.name),
        _escapeCsvField(unit.description ?? ''),
        unit.createDate?.toIso8601String() ?? '',
        unit.updatedDate?.toIso8601String() ?? '',
      ].join(',');
    }).join('\n');

    return header + rows;
  }

  String _convertOrdersToCsv(List<Order> orders) {
    // CSV format đơn giản cho đơn hàng (user-friendly)
    final header = 'ID,Trạng thái,Ngày đặt hàng,Ngày tạo,Người tạo,Số lượng SP,Tổng số lượng,Tổng giá trị,Khách hàng,SĐT khách hàng,Ghi chú,Giảm giá\n';
    final rows = orders.map((order) {
      return [
        order.id.toString(),
        _escapeCsvField(_getOrderStatusLabel(order.status)),
        order.orderDate.toIso8601String(),
        order.createdAt.toIso8601String(),
        _escapeCsvField(order.createdBy),
        order.productCount.toString(),
        order.totalAmount.toString(),
        order.totalPrice.toString(),
        _escapeCsvField(order.customer ?? 'Khách lẻ'),
        _escapeCsvField(order.customerContact ?? ''),
        _escapeCsvField(order.note ?? ''),
        order.discount?.toString() ?? '0',
      ].join(',');
    }).join('\n');

    return header + rows;
  }

  String _getOrderStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Nháp';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.done:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Request storage permission on Android
  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Kiểm tra xem đã có quyền chưa
    final hasPermission = await _checkStoragePermission();
    if (hasPermission) {
      return true;
    }

    // Nếu đã hỏi quyền trong session này, không hỏi lại
    if (_hasRequestedPermission) {
      debugPrint('Permission already requested in this session, skipping...');
      return true;
    }

    try {
      // Đánh dấu đã hỏi quyền
      _hasRequestedPermission = true;

      debugPrint('Requesting storage permissions...');

      // Thử xin quyền storage truyền thống trước
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // Nếu không được cấp quyền storage, thử xin quyền manage external storage (Android 11+)
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        return true;
      }

      // Nếu vẫn không được, log để debug
      debugPrint('Storage permissions denied. Storage: $storageStatus, Manage: $manageStatus');

      // Vẫn return true vì có thể sử dụng app-specific directory
      // mà không cần permission đặc biệt trên Android mới
      return true;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      // Vẫn return true để thử lưu vào app-specific directory
      return true;
    }
  }

  /// Check if storage permission is already granted
  Future<bool> _checkStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Kiểm tra quyền storage hiện tại
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        return true;
      }

      // Kiểm tra quyền manage external storage (Android 11+)
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isGranted) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      // Nếu có lỗi, coi như chưa có quyền
      return false;
    }
  }

  Future<File> _saveToFile(String fileName, String content) async {
    Directory directory;

    if (Platform.isAndroid) {
      // Request permission trước khi lưu file (để đảm bảo user được thông báo về quyền)
      await _requestStoragePermission();

      // Thử lưu vào external Documents directory trước (/storage/emulated/0/Documents/Đơn_và_kho_hàng)
      try {
        directory = Directory('/storage/emulated/0/Documents/Đơn_và_kho_hàng');

        // Tạo thư mục nếu chưa tồn tại
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Thử tạo file test để kiểm tra quyền ghi
        final testFile = File('${directory.path}/.test');
        await testFile.writeAsString('test');
        await testFile.delete();

        debugPrint('Using external Documents directory: ${directory.path}');
      } catch (e) {
        debugPrint('Cannot use external Documents directory: $e');

        // Fallback: Sử dụng app documents directory
        try {
          directory = await getApplicationDocumentsDirectory();
          directory = Directory('${directory.path}/Đơn_và_kho_hàng');

          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          debugPrint('Fallback to app documents directory: ${directory.path}');
        } catch (e2) {
          debugPrint('Cannot use app documents directory: $e2');
          throw Exception('Không thể tạo thư mục lưu file. Vui lòng kiểm tra quyền ứng dụng.');
        }
      }
    } else {
      // Trên iOS, sử dụng Documents directory
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/Đơn_và_kho_hàng');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }

    try {
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);

      // Log path cho debug
      debugPrint('File saved successfully to: ${file.path}');

      return file;
    } catch (e) {
      debugPrint('Error writing file: $e');
      throw Exception('Không thể lưu file. Vui lòng thử lại hoặc kiểm tra dung lượng thiết bị.');
    }
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }
}

/// Provider for DataExportService
final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(ref);
});

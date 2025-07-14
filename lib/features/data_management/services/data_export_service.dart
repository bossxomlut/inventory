import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../domain/repositories/order/order_repository.dart';
import '../../../provider/load_list.dart';

/// Service for exporting application data to different formats
class DataExportService {
  final Ref ref;

  DataExportService(this.ref);

  /// Export products to JSONL format
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

  /// Export products to CSV format
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

  /// Export categories to JSONL format
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

  /// Export categories to CSV format
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

  /// Export units to JSONL format
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

  /// Export units to CSV format
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

  /// Export orders to JSONL format
  Future<String> exportOrdersToJsonl() async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      
      // Get orders from all statuses
      final List<Order> allOrders = <Order>[];
      for (final status in OrderStatus.values) {
        final result = await orderRepo.getOrdersByStatus(status, const LoadListQuery(page: 1, pageSize: 10000));
        allOrders.addAll(result.data);
      }
      
      final jsonlData = allOrders.map((Order order) => jsonEncode({
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
      })).join('\n');
      
      final file = await _saveToFile('orders_${_getTimestamp()}.jsonl', jsonlData);
      return file.path;
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu đơn hàng: $e');
    }
  }

  /// Export orders to CSV format
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
      data['orders'] = allOrders.map((Order o) => <String, dynamic>{
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
      }).toList();

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
    final header = 'ID,Tên sản phẩm,Số lượng,Mã vạch,Danh mục,Đơn vị,Mô tả\n';
    final rows = products.map((product) {
      return [
        product.id.toString(),
        _escapeCsvField(product.name),
        product.quantity.toString(),
        _escapeCsvField(product.barcode ?? ''),
        _escapeCsvField(product.category?.name ?? ''),
        _escapeCsvField(product.unit?.name ?? ''),
        _escapeCsvField(product.description ?? ''),
      ].join(',');
    }).join('\n');
    
    return header + rows;
  }

  String _convertCategoriesToCsv(List<Category> categories) {
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
        _escapeCsvField(order.customer ?? ''),
        _escapeCsvField(order.customerContact ?? ''),
        _escapeCsvField(order.note ?? ''),
        order.discount?.toString() ?? '',
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

  Future<File> _saveToFile(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content, encoding: utf8);
    return file;
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

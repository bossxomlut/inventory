import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../domain/models/shop_type.dart';
import '../domain/models/sample_product.dart';

class ShopTypeService {
  static Future<List<Map<String, dynamic>>> loadSampleDataForShopType(ShopType shopType) async {
    try {
      final String data = await rootBundle.loadString(shopType.dataFile);
      final List<String> lines = data.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      return lines.map((line) => json.decode(line) as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to load sample data for ${shopType.name}: $e');
    }
  }

  static List<SampleProduct> convertToSampleProducts(List<Map<String, dynamic>> sampleData) {
    return sampleData.map((item) => SampleProduct.fromJson(item)).toList();
  }

  static Future<List<SampleProduct>> loadSampleProductsForShopType(ShopType shopType) async {
    final sampleData = await loadSampleDataForShopType(shopType);
    return convertToSampleProducts(sampleData);
  }
}

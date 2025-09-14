import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_chart.freezed.dart';
part 'dashboard_chart.g.dart';

/// --- Doanh thu theo ngày (Line chart) ---
@freezed
class RevenueByDay with _$RevenueByDay {
  const factory RevenueByDay({
    required DateTime date, // Ngày
    required double revenue, // Doanh thu của ngày đó
  }) = _RevenueByDay;

  factory RevenueByDay.fromJson(Map<String, dynamic> json) => _$RevenueByDayFromJson(json);
}

/// --- Top sản phẩm bán chạy (Bar chart) ---
@freezed
class TopSellingProduct with _$TopSellingProduct {
  const factory TopSellingProduct({
    required int productId, // ID sản phẩm (int)
    required String productName, // Tên sản phẩm
    required int quantitySold, // Số lượng bán
    required double revenue, // Doanh thu sản phẩm
  }) = _TopSellingProduct;

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) => _$TopSellingProductFromJson(json);
}

/// --- Cơ cấu doanh thu theo nhóm hàng (Pie chart) ---
@freezed
class RevenueByCategory with _$RevenueByCategory {
  const factory RevenueByCategory({
    required int categoryId, // ID nhóm hàng (int cho đồng bộ)
    required String categoryName, // Tên nhóm hàng
    required double revenue, // Doanh thu nhóm hàng
    required double percentage, // % trong tổng doanh thu
  }) = _RevenueByCategory;

  factory RevenueByCategory.fromJson(Map<String, dynamic> json) => _$RevenueByCategoryFromJson(json);
}

/// --- Model tổng hợp cho Dashboard Chart ---
@freezed
class DashboardChartData with _$DashboardChartData {
  const factory DashboardChartData({
    required List<RevenueByDay> revenueByDay, // Dữ liệu line chart
    required List<TopSellingProduct> topSellingProducts, // Dữ liệu bar chart
    required List<RevenueByCategory> revenueByCategory, // Dữ liệu pie chart
  }) = _DashboardChartData;

  factory DashboardChartData.fromJson(Map<String, dynamic> json) => _$DashboardChartDataFromJson(json);

  factory DashboardChartData.empty() => const DashboardChartData(
        revenueByDay: [],
        topSellingProducts: [],
        revenueByCategory: [],
      );
}

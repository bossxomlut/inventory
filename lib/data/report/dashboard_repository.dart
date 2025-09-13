import '../../domain/entities/report/dashboard_chart.dart';
import '../../domain/entities/report/dashboard_overview.dart';
import '../../domain/repositories/report/dashboard_repository.dart';

class DashboardRepositoryImpl extends DashboardRepository {
  @override
  Future<DashboardOverview> fetchOverview() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return DashboardOverview(
      todayRevenue: 3500000,
      monthRevenue: 82000000,
      totalOrders: 152,
      totalProductsSold: 430,
    );
  }

  @override
  Future<DashboardChartData> fetchCharts({
    required DateTime from,
    required DateTime to,
  }) async {
    return DashboardChartData(
      revenueByDay: List.generate(7, (i) {
        return RevenueByDay(
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          revenue: (1000000 + i * 250000).toDouble(),
        );
      }),
      topSellingProducts: [
        TopSellingProduct(productId: 1, productName: "Sản phẩm A", quantitySold: 120, revenue: 3000000),
        TopSellingProduct(productId: 2, productName: "Sản phẩm B", quantitySold: 80, revenue: 2000000),
        TopSellingProduct(productId: 3, productName: "Sản phẩm C", quantitySold: 50, revenue: 1500000),
      ],
      revenueByCategory: [
        RevenueByCategory(categoryId: 1, categoryName: "Thực phẩm", revenue: 5000000, percentage: 50),
        RevenueByCategory(categoryId: 2, categoryName: "Đồ uống", revenue: 3000000, percentage: 30),
        RevenueByCategory(categoryId: 3, categoryName: "Khác", revenue: 2000000, percentage: 20),
      ],
    );
  }
}

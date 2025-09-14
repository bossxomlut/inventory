import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/report/dashboard_charts_repository.dart';
import '../../../data/report/dashboard_repository.dart';
import '../../entities/report/dashboard_chart.dart';
import '../../entities/report/dashboard_overview.dart';

part 'dashboard_repository.g.dart';

@riverpod
DashboardRepository dashboardRepository(ref) => DashboardRepositoryImpl();

/// Định nghĩa interface cho Dashboard Repository
abstract class DashboardRepository {
  /// Lấy dữ liệu tổng quan dashboard (KPI cards)
  Future<DashboardOverview> fetchTodayOverview();
}

@riverpod
DashboardChartsRepository dashboardChartsRepository(ref) => DashboardChartsRepositoryImpl();

/// Định nghĩa interface riêng cho Charts Repository
abstract class DashboardChartsRepository {
  /// Lấy dữ liệu biểu đồ cho dashboard
  /// - Doanh thu theo ngày
  /// - Top sản phẩm bán chạy
  /// - Cơ cấu doanh thu theo nhóm hàng
  Future<DashboardChartData> fetchCharts({
    required DateTime from,
    required DateTime to,
  });
}

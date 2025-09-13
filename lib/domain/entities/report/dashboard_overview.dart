import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_overview.freezed.dart';
part 'dashboard_overview.g.dart';

@freezed
class DashboardOverview with _$DashboardOverview {
  const factory DashboardOverview({
    /// Doanh thu hôm nay
    required double todayRevenue,

    /// Doanh thu trong tháng
    required double monthRevenue,

    /// Tổng số đơn hàng đã tạo (theo khoảng thời gian hoặc toàn hệ thống)
    required int totalOrders,

    /// Tổng số lượng sản phẩm đã bán
    required int totalProductsSold,
  }) = _DashboardOverview;

  factory DashboardOverview.fromJson(Map<String, dynamic> json) => _$DashboardOverviewFromJson(json);
}

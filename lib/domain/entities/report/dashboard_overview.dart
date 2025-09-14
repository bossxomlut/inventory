import 'package:freezed_annotation/freezed_annotation.dart';

import 'difference.dart';

part 'dashboard_overview.freezed.dart';

class DashboardDifferenceData<T> {
  DashboardDifferenceData(this.value, this.difference);

  final T value;
  final DifferenceEntity? difference;
}

class TodayRevenueData extends DashboardDifferenceData<double> {
  TodayRevenueData(double value, DifferenceEntity? difference) : super(value, difference);
}

class TotalProductQuantitySoldData extends DashboardDifferenceData<int> {
  TotalProductQuantitySoldData(int value, DifferenceEntity? difference) : super(value, difference);
}

class TotalOrdersData extends DashboardDifferenceData<int> {
  TotalOrdersData(int value, DifferenceEntity? difference) : super(value, difference);
}

class TotalProductsSoldData extends DashboardDifferenceData<int> {
  TotalProductsSoldData(int value, DifferenceEntity? difference) : super(value, difference);
}

@freezed
class DashboardOverview with _$DashboardOverview {
  const factory DashboardOverview({
    /// Doanh thu hôm nay
    required TodayRevenueData todayRevenue,

    /// Tổng số đơn hàng đã tạo (theo khoảng thời gian hoặc toàn hệ thống)
    required TotalOrdersData totalOrders,

    /// Tổng số lượng sản phẩm đã bán trong tháng
    required TotalProductQuantitySoldData totalProductQuantitySold,

    /// Tổng số lượng sản phẩm đã bán
    required TotalProductsSoldData totalProductsSold,
  }) = _DashboardOverview;
}

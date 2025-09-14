import 'package:isar/isar.dart';

import '../../domain/entities/report/dashboard_overview.dart';
import '../../domain/entities/report/difference.dart';
import '../../domain/index.dart';
import '../../domain/repositories/report/dashboard_repository.dart';
import '../order/order.dart';
import '../product/inventory.dart';

class DashboardRepositoryImpl extends DashboardRepository {
  final Isar _isar = Isar.getInstance()!;

  Isar get isar => _isar;

  IsarCollection<OrderCollection> get orderCollection => isar.collection<OrderCollection>();
  IsarCollection<OrderItemCollection> get orderItemCollection => isar.collection<OrderItemCollection>();
  IsarCollection<CategoryCollection> get categoryCollection => isar.collection<CategoryCollection>();
  IsarCollection<ProductCollection> get productCollection => isar.collection<ProductCollection>();

  /// Reusable function to fetch COMPLETED orders only with flexible date filtering
  Future<List<OrderCollection>> _getCompletedOrdersWithFilters({
    DateTime? fromDate,
    DateTime? toDate,
    bool useUpdatedAt = true,
    bool useCreatedAt = false,
  }) async {
    var query = orderCollection.filter().statusEqualTo(OrderStatus.done);

    // Apply date range filter for completed orders only
    if (fromDate != null && toDate != null) {
      if (useUpdatedAt) {
        query = query.and().updatedAtIsNotNull().and().updatedAtBetween(fromDate, toDate);
      } else if (useCreatedAt) {
        query = query.and().createdAtBetween(fromDate, toDate);
      }
    }

    return await query.findAll();
  }

  /// Get completed orders for a specific date range
  Future<List<OrderCollection>> getCompletedOrders({
    DateTime? fromDate,
    DateTime? toDate,
    bool useUpdatedAt = true,
  }) async {
    return _getCompletedOrdersWithFilters(
      fromDate: fromDate,
      toDate: toDate,
      useUpdatedAt: useUpdatedAt,
    );
  }

  /// Get today's completed orders
  Future<List<OrderCollection>> getTodayCompletedOrders() async {
    final today = DateTime.now();
    final lower = DateTime(today.year, today.month, today.day);
    final upper = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _getCompletedOrdersWithFilters(
      fromDate: lower,
      toDate: upper,
      useUpdatedAt: true,
    );
  }

  /// Get this month's completed orders
  Future<List<OrderCollection>> getMonthCompletedOrders() async {
    final today = DateTime.now();
    final monthLower = DateTime(today.year, today.month, 1);
    final monthUpper = DateTime(today.year, today.month + 1, 0, 23, 59, 59);

    return _getCompletedOrdersWithFilters(
      fromDate: monthLower,
      toDate: monthUpper,
      useUpdatedAt: true,
    );
  }

  /// Get last week's completed orders
  Future<List<OrderCollection>> getLastWeekCompletedOrders() async {
    final today = DateTime.now();
    final lastWeekStart = today.subtract(Duration(days: 7));
    final lastWeekEnd = today.subtract(Duration(days: 1));

    return _getCompletedOrdersWithFilters(
      fromDate: DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day),
      toDate: DateTime(lastWeekEnd.year, lastWeekEnd.month, lastWeekEnd.day, 23, 59, 59),
      useUpdatedAt: true,
    );
  }

  /// Get last month's completed orders
  Future<List<OrderCollection>> getLastMonthCompletedOrders() async {
    final today = DateTime.now();
    final lastMonth = DateTime(today.year, today.month - 1, 1);
    final lastMonthEnd = DateTime(today.year, today.month, 0, 23, 59, 59);

    return _getCompletedOrdersWithFilters(
      fromDate: lastMonth,
      toDate: lastMonthEnd,
      useUpdatedAt: true,
    );
  }

  /// Get yesterday's completed orders
  Future<List<OrderCollection>> getYesterdayCompletedOrders() async {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    final lower = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final upper = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    return _getCompletedOrdersWithFilters(
      fromDate: lower,
      toDate: upper,
      useUpdatedAt: true,
    );
  }

  /// Calculate total revenue from a list of orders
  double calculateTotalRevenue(List<OrderCollection> orders) {
    return orders.fold<double>(
      0,
      (previousValue, element) => previousValue + (element.totalPrice ?? 0),
    );
  }

  /// Calculate total products sold from a list of orders
  int calculateTotalProductsSold(List<OrderCollection> orders) {
    return orders.fold<int>(
      0,
      (previousValue, element) => previousValue + (element.productCount ?? 0),
    );
  }

  /// Calculate total quantity of products sold from a list of orders
  int calculateTotalQuantitySold(List<OrderCollection> orders) {
    return orders.fold<int>(
      0,
      (previousValue, element) => previousValue + (element.totalAmount ?? 0),
    );
  }

  /// Calculate difference between current and previous values
  DifferenceEntity _calculateDifference(double current, double previous) {
    if (previous == 0) {
      if (current > 0) {
        return DifferenceEntity(difference: Difference.higher, percentage: 100.0);
      } else {
        return DifferenceEntity(difference: Difference.none, percentage: 0.0);
      }
    }

    final percentageChange = ((current - previous) / previous) * 100;

    if (percentageChange > 0) {
      return DifferenceEntity(difference: Difference.higher, percentage: percentageChange.abs());
    } else if (percentageChange < 0) {
      return DifferenceEntity(difference: Difference.lower, percentage: percentageChange.abs());
    } else {
      return DifferenceEntity(difference: Difference.equal, percentage: 0.0);
    }
  }

  /// Calculate difference for integer values
  DifferenceEntity _calculateDifferenceInt(int current, int previous) {
    return _calculateDifference(current.toDouble(), previous.toDouble());
  }

  @override
  Future<DashboardOverview> fetchTodayOverview() async {
    // Get current period data
    final todayCompletedOrders = await getTodayCompletedOrders();
    final monthCompletedOrders = await getMonthCompletedOrders();

    // Get previous period data for comparison
    final yesterdayCompletedOrders = await getYesterdayCompletedOrders();

    // Calculate current period metrics
    final todayRevenueValue = calculateTotalRevenue(todayCompletedOrders);
    final totalProductQuantitySold = calculateTotalQuantitySold(monthCompletedOrders);
    final totalOrdersValue = todayCompletedOrders.length;
    final totalProductsSoldValue = calculateTotalProductsSold(todayCompletedOrders);

    // Calculate previous period metrics for comparison
    final yesterdayRevenueValue = calculateTotalRevenue(yesterdayCompletedOrders);
    final yesterdayProductQuantitySold = calculateTotalQuantitySold(yesterdayCompletedOrders);
    final yesterdayOrdersValue = yesterdayCompletedOrders.length;
    final yesterdayProductsSoldValue = calculateTotalProductsSold(yesterdayCompletedOrders);

    // Calculate differences
    final todayRevenueDifference = _calculateDifference(todayRevenueValue, yesterdayRevenueValue);
    final totalProductQuantityDifference =
        _calculateDifferenceInt(totalProductQuantitySold, yesterdayProductQuantitySold);
    final totalOrdersDifference = _calculateDifferenceInt(totalOrdersValue, yesterdayOrdersValue);
    final totalProductsSoldDifference = _calculateDifferenceInt(totalProductsSoldValue, yesterdayProductsSoldValue);

    return DashboardOverview(
      todayRevenue: TodayRevenueData(todayRevenueValue, todayRevenueDifference),
      totalProductQuantitySold: TotalProductQuantitySoldData(totalProductQuantitySold, totalProductQuantityDifference),
      totalOrders: TotalOrdersData(totalOrdersValue, totalOrdersDifference),
      totalProductsSold: TotalProductsSoldData(totalProductsSoldValue, totalProductsSoldDifference),
    );
  }
}

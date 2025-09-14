import 'package:isar/isar.dart';

import '../../domain/entities/report/dashboard_chart.dart';
import '../../domain/index.dart';
import '../../domain/repositories/report/dashboard_repository.dart';
import '../order/order.dart';
import '../product/inventory.dart';

class DashboardChartsRepositoryImpl extends DashboardChartsRepository {
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

  @override
  Future<DashboardChartData> fetchCharts({
    required DateTime from,
    required DateTime to,
  }) async {
    // Get completed orders in the date range
    final orders = await getCompletedOrders(fromDate: from, toDate: to, useUpdatedAt: true);

    // Generate revenue by day data
    final revenueByDay = await _generateRevenueByDay(orders, from, to);

    // Generate top selling products data
    final topSellingProducts = await _generateTopSellingProducts(orders);

    // Generate revenue by category data (mock for now since we don't have product categories)
    final revenueByCategory = await _generateRevenueByCategory(orders);

    return DashboardChartData(
      revenueByDay: revenueByDay,
      topSellingProducts: topSellingProducts,
      revenueByCategory: revenueByCategory,
    );
  }

  /// Generate revenue by day chart data from completed orders (last 7 days only)
  Future<List<RevenueByDay>> _generateRevenueByDay(
    List<OrderCollection> orders,
    DateTime from,
    DateTime to,
  ) async {
    final Map<String, double> dailyRevenue = {};

    // Calculate the last 7 days from the 'to' date
    final last7DaysStart = to.subtract(Duration(days: 6)); // 6 days back + today = 7 days
    final last7DaysEnd = to;

    // Initialize last 7 days with 0 revenue
    for (DateTime date = last7DaysStart;
        date.isBefore(last7DaysEnd.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailyRevenue[dateKey] = 0.0;
    }

    // Calculate actual revenue for each day (only for last 7 days)
    for (final order in orders) {
      final orderDate = order.updatedAt ?? order.createdAt;

      // Only include orders from the last 7 days
      if (orderDate.isAfter(last7DaysStart.subtract(Duration(days: 1))) &&
          orderDate.isBefore(last7DaysEnd.add(Duration(days: 1)))) {
        final dateKey =
            '${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}-${orderDate.day.toString().padLeft(2, '0')}';

        if (dailyRevenue.containsKey(dateKey)) {
          dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + (order.totalPrice ?? 0);
        }
      }
    }

    // Convert to RevenueByDay objects
    return dailyRevenue.entries.map((entry) {
      final dateParts = entry.key.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      return RevenueByDay(date: date, revenue: entry.value);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Generate top selling products data from order items
  Future<List<TopSellingProduct>> _generateTopSellingProducts(List<OrderCollection> orders) async {
    if (orders.isEmpty) {
      return [];
    }

    // Get all order IDs
    final orderIds = orders.map((o) => o.id).toList();

    // Get all order items for these orders
    final orderItems = await orderItemCollection.filter().anyOf(
      orderIds,
      (QueryBuilder<OrderItemCollection, OrderItemCollection, QFilterCondition> q, element) {
        return q.orderIdEqualTo(element);
      },
    ).findAll();

    // Group by product and calculate totals
    final Map<int, Map<String, dynamic>> productData = {};

    for (final item in orderItems) {
      final productId = item.productId;

      if (productData.containsKey(productId)) {
        productData[productId]!['quantitySold'] += item.quantity;
        productData[productId]!['revenue'] += (item.price * item.quantity);
      } else {
        productData[productId] = {
          'productName': item.productName,
          'quantitySold': item.quantity,
          'revenue': (item.price * item.quantity),
        };
      }
    }

    // Convert to TopSellingProduct objects and sort by quantity sold
    final topProducts = productData.entries
        .map((entry) => TopSellingProduct(
              productId: entry.key,
              productName: entry.value['productName'] as String,
              quantitySold: entry.value['quantitySold'] as int,
              revenue: entry.value['revenue'] as double,
            ))
        .toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    // Return top 5 products
    return topProducts.take(5).toList();
  }

  Future<List<RevenueByCategory>> _generateRevenueByCategory(List<OrderCollection> orders) async {
    if (orders.isEmpty) {
      return [];
    }

    //get all unit
    final units = await categoryCollection.where().findAll();
    //find all order items mapping with units if not created not default to uncategorized
    final Map<int, String> unitMap = {
      for (var unit in units) unit.id: unit.name,
    };

    //find all order items for these orders
    final orderIds = orders.map((o) => o.id).toList();
    final orderItems = await orderItemCollection.filter().anyOf(
      orderIds,
      (QueryBuilder<OrderItemCollection, OrderItemCollection, QFilterCondition> q, element) {
        return q.orderIdEqualTo(element);
      },
    ).findAll();

    //group by category and calculate totals
    final Map<String, double> categoryData = {};

    for (final item in orderItems) {
      //get product information to find category
      final product = await productCollection.get(item.productId);
      if (product == null) {
        continue; //skip if product not found
      }

      final categoryName = product.category?.value?.name ?? 'Uncategorized';
      if (categoryData.containsKey(categoryName)) {
        categoryData[categoryName] = (categoryData[categoryName] ?? 0) + (item.price * item.quantity);
      } else {
        categoryData[categoryName] = (item.price * item.quantity);
      }
    }

    // Convert to RevenueByCategory objects and sort by revenue
    final revenueByCategory = categoryData.entries
        .map((entry) => RevenueByCategory(
              categoryName: entry.key,
              revenue: entry.value,
              categoryId: units
                  .firstWhere((u) => u.name == entry.key, orElse: () => CategoryCollection()..name = 'Uncategorized')
                  .id,
              percentage: 0, // Will calculate later
            ))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Calculate total revenue for percentage calculation
    final totalRevenue = revenueByCategory.fold<double>(0, (sum, item) => sum + item.revenue);

    // Calculate percentage for each category by map

    return revenueByCategory.map((category) {
      final percentage = totalRevenue > 0 ? (category.revenue / totalRevenue) * 100 : 0;
      return RevenueByCategory(
        categoryName: category.categoryName,
        revenue: category.revenue,
        categoryId: category.categoryId,
        percentage: percentage.toDouble(),
      );
    }).toList();
  }
}

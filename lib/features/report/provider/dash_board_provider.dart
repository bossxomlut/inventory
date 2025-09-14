import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/report/dashboard_chart.dart';
import '../../../domain/entities/report/dashboard_overview.dart';
import '../../../domain/repositories/report/dashboard_repository.dart';

/// Provider load dữ liệu KPI cards (DashboardOverview)
final dashboardOverviewProvider =
    FutureProvider.autoDispose.family<DashboardOverview, DateTimeRange>((ref, range) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.fetchTodayOverview(
    from: range.start,
    to: range.end,
  );
});

/// Provider load dữ liệu biểu đồ (DashboardChartData)
final dashboardChartsProvider =
    FutureProvider.autoDispose.family<DashboardChartData, DateTimeRange>((ref, range) async {
  final link = ref.keepAlive();
  final repo = ref.read(dashboardChartsRepositoryProvider);

  return repo.fetchCharts(from: range.start, to: range.end);
});

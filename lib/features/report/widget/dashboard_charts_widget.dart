import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/report/dashboard_chart.dart';
import 'dashboard_chart_container.dart';
import 'full_screen_chart_page.dart';

class DashboardChartsWidget extends StatelessWidget {
  final DashboardChartData data;

  const DashboardChartsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardChartContainer(
          title: "Doanh thu theo ngày",
          chart: RevenueLineChart(data: data.revenueByDay),
          onExpand: () {
            FullScreenChartPage.show(
              context,
              title: "Doanh thu theo ngày",
              chart: RevenueLineChart(data: data.revenueByDay),
            );
          },
        ),
        DashboardChartContainer(
          title: "Top 5 sản phẩm bán chạy",
          chart: TopProductsBarChart(data: data.topSellingProducts),
          onExpand: () {
            FullScreenChartPage.show(
              context,
              title: "Top 5 sản phẩm bán chạy",
              chart: TopProductsBarChart(data: data.topSellingProducts),
            );
          },
        ),
        DashboardChartContainer(
          title: "Cơ cấu doanh thu theo nhóm hàng",
          chart: RevenueCategoryPieChart(data: data.revenueByCategory),
          onExpand: () {
            FullScreenChartPage.show(
              context,
              title: "Cơ cấu doanh thu theo nhóm hàng",
              chart: RevenueCategoryPieChart(data: data.revenueByCategory),
            );
          },
        ),
      ],
    );
  }
}

/// ------------------
/// Line Chart: Doanh thu theo ngày
/// ------------------
class RevenueLineChart extends StatelessWidget {
  final List<RevenueByDay> data;

  const RevenueLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.revenue);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                final day = data[index].date.day;
                return Text("$day");
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            spots: spots,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

/// ------------------
/// Bar Chart: Top sản phẩm bán chạy
/// ------------------
class TopProductsBarChart extends StatelessWidget {
  final List<TopSellingProduct> data;

  const TopProductsBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                return Text(
                  data[index].productName,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.quantitySold.toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// ------------------
/// Pie Chart: Cơ cấu doanh thu theo nhóm hàng
/// ------------------
class RevenueCategoryPieChart extends StatelessWidget {
  final List<RevenueByCategory> data;

  const RevenueCategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return PieChartSectionData(
            value: item.revenue,
            title: "${item.percentage.toStringAsFixed(1)}%",
            color: colors[index % colors.length],
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}

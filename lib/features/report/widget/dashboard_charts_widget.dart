import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/helpers/double_utils.dart';
import '../../../core/index.dart';
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
          chart: AspectRatio(aspectRatio: 4 / 3, child: RevenueLineChart(data: data.revenueByDay)),
          onExpand: () {
            FullScreenChartPage.show(
              context,
              title: "Doanh thu theo ngày",
              chart: RevenueLineChart(data: data.revenueByDay),
            );
          },
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        DashboardChartContainer(
          title: "Top 5 sản phẩm bán chạy",
          chart: AspectRatio(
            aspectRatio: 1,
            child: TopProductsBarChart(data: data.topSellingProducts),
          ),
          onExpand: () {
            FullScreenChartPage.show(
              context,
              title: "Top 5 sản phẩm bán chạy",
              chart: TopProductsBarChart(data: data.topSellingProducts),
            );
          },
        ),
        const SizedBox(height: 12),
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
      return FlSpot(e.key.toDouble(), e.value.revenue / 1000);
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
            dotData: const FlDotData(show: true),
            curveSmoothness: 0.0,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: BarChart(
            BarChartData(
              maxY: data.first.quantitySold.toDouble() + 1,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: data.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.quantitySold.toDouble(),
                      color: e.value.productName.colorFromString,
                      width: 20,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        //legend
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 4,
            children: data.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: e.productName.colorFromString,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.productName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
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

    final theme = Theme.of(context);

    return Column(
      children: [
        BubbleCategoryChart(data: data),
        const SizedBox(height: 16),
        Card(
          color: theme.scaffoldBackgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                for (int i = 0; i < data.length; i++)
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          data[i].categoryName,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 60,
                        color: theme.colorScheme.secondaryContainer,
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Flexible(
                              child: LayoutBuilder(builder: (context, constraints) {
                                final widthPercentage = (data[i].percentage / 100).clamp(0.0, 1.0);
                                return FractionallySizedBox(
                                  widthFactor: widthPercentage,
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondaryContainer,
                                      border: Border(
                                        right: BorderSide(
                                          color: data[i].categoryName.colorFromString,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${data[i].revenue.priceFormat()}",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BubbleCategoryChart extends StatelessWidget {
  const BubbleCategoryChart({super.key, required this.data});
  final List<RevenueByCategory> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    // Lấy top 3 theo percentage
    final topData = [...data]..sort((a, b) => b.percentage.compareTo(a.percentage));
    final top3 = topData.take(3).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleSize = screenWidth * 0.35; // ~35% width
    final minBubbleSize = screenWidth * 0.20; // ~20% width

    double _bubbleSize(double percentage) {
      // Scale theo percentage nhưng có giới hạn min/max
      final scaled = screenWidth * (percentage / 100);
      return scaled.clamp(minBubbleSize, maxBubbleSize);
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        alignment: Alignment.center,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              for (int i = 0; i < top3.length; i++)
                _bubble(
                  label: top3[i].categoryName,
                  percent: top3[i].percentage,
                  color: top3[i].categoryName.colorFromString,
                  size: _bubbleSize(top3[i].percentage),
                  alignment: _alignmentForIndex(i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- Bubble widget ---
  Widget _bubble({
    required String label,
    required double percent,
    required Color color,
    required double size,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${percent.toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Vị trí bubble theo index (3 loại)
  Alignment _alignmentForIndex(int index) {
    switch (index) {
      case 0:
        return Alignment(-0.7, -0.5);
      case 1:
        return Alignment(0.6, 0.2);
      case 2:
        return Alignment(-0.2, 0.8);
      default:
        return Alignment.center;
    }
  }
}

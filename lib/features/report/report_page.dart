import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with SingleTickerProviderStateMixin {
  int _tabIndex = 0; // 0: Sale, 1: Product
  DateTimeRange? _selectedRange;
  int _filterDays = 30;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  List<BarChartGroupData> _barGroups = [];
  double _totalRevenue = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
    // TODO: Replace with real data fetch
    _orders = _mockOrders();
    _applyFilter();
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    DateTime fromDate = _selectedRange?.start ?? now.subtract(Duration(days: _filterDays));
    DateTime toDate = _selectedRange?.end ?? now;
    _filteredOrders = _orders.where((order) {
      final date = order['date'] as DateTime;
      return order['status'] == 'completed' &&
          date.isAfter(fromDate.subtract(const Duration(days: 1))) &&
          date.isBefore(toDate.add(const Duration(days: 1)));
    }).toList();
    _totalRevenue = _filteredOrders.fold(0.0, (sum, o) => sum + (o['total'] as double));
    _barGroups = _buildBarGroups(fromDate, toDate);
    setState(() {});
  }

  List<BarChartGroupData> _buildBarGroups(DateTime from, DateTime to) {
    final days = to.difference(from).inDays + 1;
    final List<BarChartGroupData> groups = [];
    for (int i = 0; i < days; i++) {
      final day = from.add(Duration(days: i));
      final dayTotal = _filteredOrders
          .where((o) => DateUtils.isSameDay(o['date']! as DateTime, day))
          .fold(0.0, (sum, o) => sum + (o['total'] as double));
      groups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: dayTotal, color: Colors.blue)]));
    }
    return groups;
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        _filterDays = 0;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sale'),
            Tab(text: 'Product'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // SALE TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tổng quan
                _ProfitCard(total: _totalRevenue),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoCard(title: 'Total Orders', value: _filteredOrders.length.toString()),
                    const SizedBox(width: 12),
                    _InfoCard(title: 'Total Products', value: '25'),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter
                Row(
                  children: [
                    FilterChip(
                      label: const Text('30 ngày'),
                      selected: _filterDays == 30,
                      onSelected: (_) {
                        setState(() {
                          _filterDays = 30;
                          _selectedRange = null;
                        });
                        _applyFilter();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('60 ngày'),
                      selected: _filterDays == 60,
                      onSelected: (_) {
                        setState(() {
                          _filterDays = 60;
                          _selectedRange = null;
                        });
                        _applyFilter();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('90 ngày'),
                      selected: _filterDays == 90,
                      onSelected: (_) {
                        setState(() {
                          _filterDays = 90;
                          _selectedRange = null;
                        });
                        _applyFilter();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Tùy chọn'),
                      selected: _filterDays == 0,
                      onSelected: (_) => _pickCustomRange(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Biểu đồ doanh thu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 220,
                    child: _barGroups.isEmpty
                        ? const Center(child: Text('Không có dữ liệu'))
                        : LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(_barGroups.length, (i) {
                                    final y = _barGroups[i].barRods.first.toY;
                                    return FlSpot(i.toDouble(), y);
                                  }),
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.15)),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final day = (_selectedRange?.start ?? DateTime.now().subtract(Duration(days: _filterDays)))
                                          .add(Duration(days: value.toInt()));
                                      return Text(DateFormat('dd/MM').format(day), style: const TextStyle(fontSize: 10));
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: false),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Target Prediction
                _TargetPredictionCard(target: 30000000, current: _totalRevenue),
              ],
            ),
          ),
          // PRODUCT TAB (placeholder)
          Center(child: Text('Product report coming soon...')),
        ],
      ),
    );
  }

  // Mock data for demo
  List<Map<String, dynamic>> _mockOrders() {
    final now = DateTime.now();
    return List.generate(120, (i) {
      final date = now.subtract(Duration(days: i));
      return {
        'date': date,
        'status': i % 3 == 0 ? 'completed' : 'pending',
        'total': (i % 3 == 0) ? (100000 + (i * 1000)).toDouble() : 0.0,
      };
    });
  }
}

class _ProfitCard extends StatelessWidget {
  final double total;
  const _ProfitCard({required this.total});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profit amount', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('${total.toStringAsFixed(0)} đ',
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              const Text('+15%', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              const Text('From previous week', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  const _InfoCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TargetPredictionCard extends StatelessWidget {
  final double target;
  final double current;
  const _TargetPredictionCard({required this.target, required this.current});
  @override
  Widget build(BuildContext context) {
    final double percent = (current / target).clamp(0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Prediction', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${target.toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${current.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.orange.withOpacity(0.2),
            color: Colors.orange,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 4),
          Text('${(percent * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }
}

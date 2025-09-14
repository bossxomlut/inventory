import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/helpers/format_utils.dart';
import '../../provider/index.dart';
import '../../shared_widgets/index.dart';
import 'provider/dash_board_provider.dart';
import 'widget/dashboard_charts_widget.dart';
import 'widget/dashboard_summary_widget.dart';

@RoutePage()
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    'Tổng quan',
    'Đơn hàng',
    'Tồn kho',
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Báo cáo',
        bottom: TabBar(
          labelStyle: theme.textMedium15Default.copyWith(color: Colors.white),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          controller: _tabController,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 12),
                sliver: SliverToBoxAdapter(
                  child: DashboardWidget(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 12),
                sliver: SliverToBoxAdapter(
                  child: DashboardWidget2(
                    DateTime.now().subtract(const Duration(days: 7)),
                    DateTime.now(),
                  ),
                ),
              ),
            ],
          ),
          Placeholder(),
          Placeholder(),
        ],
      ),
    );
  }
}

class DashboardWidget extends ConsumerWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(dashboardOverviewProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KPI Cards
        overviewAsync.when(
          data: (overview) => Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              padding: EdgeInsets.zero,
              children: [
                DashboardSummaryWidget(
                  title: "Doanh thu",
                  value: "${overview.todayRevenue.value.priceFormat()}",
                  difference: overview.todayRevenue.difference,
                ),
                DashboardSummaryWidget(
                  title: "Tổng đơn hàng",
                  value: "${overview.totalOrders.value.displayFormat()}",
                  difference: overview.totalOrders.difference,
                ),
                DashboardSummaryWidget(
                  title: "Sản phẩm đã bán",
                  value: "${overview.totalProductsSold.value.displayFormat()}",
                  difference: overview.totalProductsSold.difference,
                ),
                DashboardSummaryWidget(
                  title: "Số lượng đã bán",
                  value: "${overview.totalProductQuantitySold.value.displayFormat()}",
                  difference: overview.totalProductQuantitySold.difference,
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ],
    );
  }
}

class DashboardWidget2 extends ConsumerWidget {
  const DashboardWidget2(this.startDate, this.endDate, {super.key});
  final DateTime startDate;
  final DateTime endDate;

  DateTimeRange get dateRange => DateTimeRange(start: startDate, end: endDate);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartsAsync = ref.watch(dashboardChartsProvider(dateRange));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Charts
        chartsAsync.when(
          data: (charts) => DashboardChartsWidget(data: charts),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Error: $e"),
        ),
      ],
    );
  }
}

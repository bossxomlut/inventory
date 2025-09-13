import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/helpers/double_utils.dart';
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

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Báo cáo'),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: DashboardWidget(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: DashboardWidget2(
                DateTime.now().subtract(const Duration(days: 7)),
                DateTime.now(),
              ),
            ),
          ),
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
        // title
        Text(
          "Tổng quan",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        // KPI Cards
        overviewAsync.when(
          data: (overview) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            padding: EdgeInsets.zero,
            children: [
              DashboardSummaryWidget(
                title: "Doanh thu hôm nay",
                value: "${overview.todayRevenue.priceFormat()}",
                color: Colors.green,
                icon: Icons.monetization_on,
              ),
              DashboardSummaryWidget(
                title: "Doanh thu tháng",
                value: "${overview.monthRevenue.priceFormat()}",
                color: Colors.blue,
                icon: Icons.bar_chart,
              ),
              DashboardSummaryWidget(
                title: "Tổng đơn hàng",
                value: "${overview.totalOrders}",
                color: Colors.orange,
                icon: Icons.shopping_cart,
              ),
              DashboardSummaryWidget(
                title: "Sản phẩm đã bán",
                value: "${overview.totalProductsSold}",
                color: Colors.purple,
                icon: Icons.inventory_2,
              ),
            ],
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
        // title
        Text(
          "Biểu đồ",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/helpers/date_time_utils.dart';
import '../../core/helpers/double_utils.dart';
import '../../core/helpers/format_utils.dart';
import '../../domain/entities/report/dashboard_chart.dart';
import '../../domain/entities/report/difference.dart';
import '../../provider/index.dart';
import '../../shared_widgets/index.dart';
import '../product/provider/product_filter_provider.dart';
import '../setting/provider/currency_settings_provider.dart';
import 'provider/dash_board_provider.dart';
import 'widget/dashboard_charts_widget.dart';
import 'widget/dashboard_summary_widget.dart';
import 'widget/filter_widget.dart';

@RoutePage()
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabKeys = const [
    LKey.reportTabOverview,
    LKey.reportTabOrders,
    LKey.reportTabInventory,
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);
    return Scaffold(
      appBar: CustomAppBar(
        title: t(LKey.reportPageTitle),
        // bottom: TabBar(
        //   labelStyle: theme.textMedium15Default.copyWith(color: Colors.white),
        //   labelColor: Colors.white,
        //   unselectedLabelColor: Colors.white70,
        //   controller: _tabController,
        //   tabs: tabKeys.map((key) => Tab(text: t(key))).toList(),
        //   isScrollable: true,
        //   tabAlignment: TabAlignment.start,
        // ),
      ),
      body: const OverviewContent(),
      // body: TabBarView(
      //   controller: _tabController,
      //   children: [
      //     const OverviewContent(),
      //     const Placeholder(),
      //     const Placeholder(),
      //   ],
      // ),
    );
  }
}

class OverviewContent extends ConsumerStatefulWidget {
  const OverviewContent({super.key});

  @override
  ConsumerState createState() => _OverviewContentState();
}

class _OverviewContentState extends ConsumerState<OverviewContent> {
  TimeFilterType selectedFilter = TimeFilterType.today;

  DateTimeRange? customDateRange;

  DateTime get startDate => DateTimeUtils.getOnlyDate(
      selectedFilter.startDate ?? customDateRange?.start ?? DateTime.now());

  DateTime get endDate => DateTimeUtils.getEndOfDay(
      selectedFilter.endDate ?? customDateRange?.end ?? DateTime.now());

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 68,
          title: TabTimeFilterMenuWidget(
            selected: selectedFilter,
            onSelected: (value) {
              switch (value) {
                case TimeFilterType.custom:
                  showDateRangePicker(
                    context: context,
                    locale: context.locale,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: customDateRange ??
                        DateTimeRange(
                          start: DateTimeUtils.getOnlyDate(
                              DateTime.now().subtract(const Duration(days: 7))),
                          end: DateTimeUtils.getEndOfDay(DateTime.now()),
                        ),
                  ).then((pickedRange) {
                    if (pickedRange != null) {
                      setState(() {
                        selectedFilter = value;
                        final start =
                            DateTimeUtils.getOnlyDate(pickedRange.start);
                        final end = DateTimeUtils.getEndOfDay(pickedRange.end);

                        customDateRange = DateTimeRange(start: start, end: end);
                      });
                    }
                  });
                  break;
                default:
                  setState(() {
                    selectedFilter = value;
                    customDateRange = null;
                  });
              }
            },
          ),
          leading: const SizedBox(),
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          centerTitle: false,
          leadingWidth: 0,
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 12),
          sliver: SliverToBoxAdapter(
            child: DashboardWidget(
              startDate,
              endDate,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 12),
          sliver: SliverToBoxAdapter(
            child: DashboardWidget2(
              startDate,
              endDate,
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardWidget extends ConsumerWidget {
  const DashboardWidget(this.startDate, this.endDate, {super.key});
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(dashboardOverviewProvider(
        DateTimeRange(start: startDate, end: endDate)));
    ref.watch(currencySettingsControllerProvider);
    String t(String key, {Map<String, String>? namedArgs}) =>
        key.tr(context: context, namedArgs: namedArgs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                  title: t(LKey.reportSummaryRevenue),
                  value: "${overview.todayRevenue.value.priceFormat()}",
                  difference: overview.todayRevenue.difference,
                ),
                DashboardSummaryWidget(
                  title: t(LKey.reportSummaryTotalOrders),
                  value: "${overview.totalOrders.value.displayFormat()}",
                  difference: overview.totalOrders.difference,
                ),
                DashboardSummaryWidget(
                  title: t(LKey.reportSummaryProductsSold),
                  value: "${overview.totalProductsSold.value.displayFormat()}",
                  difference: overview.totalProductsSold.difference,
                ),
                DashboardSummaryWidget(
                  title: t(LKey.reportSummaryQuantitySold),
                  value:
                      "${overview.totalProductQuantitySold.value.displayFormat()}",
                  difference: overview.totalProductQuantitySold.difference,
                ),
              ],
            ),
          ),
          loading: () => Container(
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
                  title: t(LKey.reportSummaryRevenue),
                  value: 0.0.priceFormat(),
                  difference: DifferenceEntity.empty(),
                ),
                DashboardSummaryWidget(
                  title: t(LKey.reportSummaryTotalOrders),
                  value: 0.0.displayFormat(),
                  difference: DifferenceEntity.empty(),
                ),
                DashboardSummaryWidget(
                  title: t(LKey.reportSummaryProductsSold),
                  value: 0.0.displayFormat(),
                  difference: DifferenceEntity.empty(),
                ),
                DashboardSummaryWidget(
                  title: t(LKey.reportSummaryQuantitySold),
                  value: 0.0.displayFormat(),
                  difference: DifferenceEntity.empty(),
                ),
              ],
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              t(
                LKey.commonErrorWithMessage,
                namedArgs: {'error': '$e'},
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
    ref.watch(currencySettingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Charts
        chartsAsync.when(
          data: (charts) => DashboardChartsWidget(data: charts),
          loading: () =>
              DashboardChartsWidget(data: DashboardChartData.empty()),
          error: (e, _) => Text(
            LKey.commonErrorWithMessage.tr(
              context: context,
              namedArgs: {'error': '$e'},
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

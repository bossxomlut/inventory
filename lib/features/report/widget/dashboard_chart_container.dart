import 'package:flutter/material.dart';

class DashboardChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;
  final bool showTitle;
  final VoidCallback? onExpand;

  const DashboardChartContainer({
    super.key,
    required this.title,
    required this.chart,
    this.showTitle = true,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTitle) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.open_in_full),
                  onPressed: onExpand,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }
}

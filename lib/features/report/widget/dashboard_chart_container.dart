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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTitle) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_full),
                    onPressed: onExpand,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              height: 200, // có thể cho thành tham số
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

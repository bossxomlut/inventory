import 'package:flutter/material.dart';

import '../../../domain/entities/report/difference.dart';
import 'difference_widget.dart';

class DashboardSummaryWidget extends StatelessWidget {
  final String title;
  final String value;
  final DifferenceEntity? difference;

  const DashboardSummaryWidget({
    super.key,
    required this.title,
    required this.value,
    this.difference,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (difference != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: DifferenceWidget(difference!),
              ),
            ),
        ],
      ),
    );
  }
}

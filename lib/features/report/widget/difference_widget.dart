import 'package:flutter/material.dart';

import '../../../domain/entities/report/difference.dart';

class DifferenceWidget extends StatelessWidget {
  const DifferenceWidget(this.difference, {super.key});

  final DifferenceEntity difference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (difference.difference) {
      case Difference.none:
        //create not display
        return const SizedBox.shrink();
      case Difference.higher:
        final isPositive = difference.percentage >= 0;
        final color = Colors.green;
        final formattedValue = "${isPositive ? '+' : ''}${difference.percentage.toStringAsFixed(2)}%";

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.trending_up_outlined,
                    color: color,
                    size: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                formattedValue,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      case Difference.lower:
        final isNegative = difference.percentage <= 0;
        final color = Colors.red;
        final formattedValue = "${isNegative ? '' : '-'}${difference.percentage.toStringAsFixed(2)}%";

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.trending_down_outlined,
                  color: color,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                formattedValue,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      case Difference.equal:
        final color = theme.colorScheme.outline;
        final formattedValue = "${0.toStringAsFixed(2)}%";

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.trending_flat_outlined,
                  color: color,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                formattedValue,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
    }
  }
}

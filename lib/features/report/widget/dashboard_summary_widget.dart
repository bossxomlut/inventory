import 'package:flutter/material.dart';

class DashboardSummaryWidget extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;
  final IconData? icon;

  const DashboardSummaryWidget({
    super.key,
    required this.title,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Title trên cùng một dòng
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: color ?? theme.primaryColor,
                    size: 18,
                  ),
                if (icon != null) const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Value nổi bật
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color ?? theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

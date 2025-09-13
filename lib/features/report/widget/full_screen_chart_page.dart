import 'package:flutter/material.dart';

class FullScreenChartPage extends StatelessWidget {
  final String title;
  final Widget chart;

  const FullScreenChartPage({
    super.key,
    required this.title,
    required this.chart,
  });

  /// Hàm tiện ích để mở trang full screen
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget chart,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => FullScreenChartPage(title: title, chart: chart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: RotatedBox(
          quarterTurns: 1, // Xoay ngang 90 độ
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: chart,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppStepWidget extends StatelessWidget {
  const AppStepWidget({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.thickness = 4.0,
    this.spacing = 4.0, // Khoảng cách giữa các thanh
    this.borderRadius = 5.0, // Bo góc cho thanh
  });

  final int totalSteps; // Tổng số bước
  final int currentStep; // Bước hiện tạiàu của thanh chưa hoàn thành
  final double thickness; // Độ dày của thanh
  final double spacing; // Khoảng cách giữa các thanh
  final double borderRadius; // Độ bo góc cho các thanh

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? spacing : 0),
            height: thickness,
            // Chiều cao của thanh Divider
            decoration: BoxDecoration(
              color: index <= currentStep ? theme.primaryColor : theme.disabledColor,
              borderRadius: BorderRadius.circular(borderRadius), // Bo góc thanh
            ),
          ),
        );
      }),
    );
  }
}

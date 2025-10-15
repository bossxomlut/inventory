import 'package:flutter/material.dart';

/// Model for onboarding content data
class OnboardingContent {
  final String titleKey;
  final String descriptionKey;
  final String subtitleKey;
  final String imagePath;
  final IconData icon;

  const OnboardingContent({
    required this.titleKey,
    required this.descriptionKey,
    required this.subtitleKey,
    required this.imagePath,
    required this.icon,
  });
}

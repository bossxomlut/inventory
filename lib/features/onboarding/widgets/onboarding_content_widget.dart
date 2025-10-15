import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../provider/theme.dart';
import '../../../resources/string.dart';
import 'onboarding_content.dart';

/// Widget to display onboarding content
class OnboardingContentWidget extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingContentWidget({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final double screenHeight = MediaQuery.of(context).size.height;

    final String subtitle = content.subtitleKey.tr(context: context);
    final String title = content.titleKey.tr(context: context);
    final String description = content.descriptionKey.tr(context: context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            height: screenHeight * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorPrimary.withOpacity(0.1),
                  theme.colorPrimary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    content.icon,
                    size: 64,
                    color: theme.colorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: theme.textMedium14Default.copyWith(
                    color: theme.colorPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: theme.headingSemibold24Default.copyWith(
              color: theme.colorTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              description,
              style: theme.textRegular16Default.copyWith(
                color: theme.colorTextSubtle,
                height: 1.6,
              ),
              textAlign: _isFeaturePage ? TextAlign.left : TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isFeaturePage =>
      content.subtitleKey == LKey.onboardingSlideFeaturesSubtitle;
}

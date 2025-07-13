import 'package:flutter/material.dart';

import '../../../provider/theme.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Image/Icon container
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
                    _getIconForContent(content.title),
                    size: 64,
                    color: theme.colorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getSubtitleForContent(content.title),
                  style: theme.textMedium14Default.copyWith(
                    color: theme.colorPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            content.title,
            style: theme.headingSemibold24Default.copyWith(
              color: theme.colorTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description with better formatting
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              content.description,
              style: theme.textRegular16Default.copyWith(
                color: theme.colorTextSubtle,
                height: 1.6,
              ),
              textAlign: _isFeaturePage() ? TextAlign.left : TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  bool _isFeaturePage() {
    return content.title.contains('Tính năng');
  }

  IconData _getIconForContent(String title) {
    if (title.contains('Chào mừng')) {
      return Icons.inventory_2_outlined;
    } else if (title.contains('Tính năng')) {
      return Icons.featured_play_list_outlined;
    } else if (title.contains('Dữ liệu')) {
      return Icons.security_outlined;
    }
    return Icons.apps;
  }

  String _getSubtitleForContent(String title) {
    if (title.contains('Chào mừng')) {
      return 'Quản lý kho hàng thông minh';
    } else if (title.contains('Tính năng')) {
      return 'Mọi thứ bạn cần trong một ứng dụng';
    } else if (title.contains('Dữ liệu')) {
      return 'Bảo mật và kiểm soát hoàn toàn';
    }
    return '';
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/theme.dart';
import '../../resources/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import 'onboarding_service.dart';
import 'widgets/onboarding_content.dart';
import 'widgets/onboarding_content_widget.dart';

@RoutePage()
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _onboardingData = [
    const OnboardingContent(
      title: 'Chào mừng đến với Đơn và kho hàng',
      description:
          'Ứng dụng quản lý kho hàng thông minh, giúp bạn dễ dàng theo dõi sản phẩm, quản lý tồn kho và kiểm soát đơn hàng một cách hiệu quả. Tất cả trong một giao diện đơn giản và trực quan.',
      imagePath: 'assets/images/onboarding_welcome.png',
    ),
    const OnboardingContent(
      title: 'Tính năng nổi bật',
      description:
          '• Quản lý sản phẩm và danh mục\n• Kiểm kê tự động với mã QR\n• Theo dõi đơn hàng và giao dịch\n• Báo cáo chi tiết và thống kê\n• Xuất nhập dữ liệu dễ dàng\n• Giao diện thân thiện với người dùng',
      imagePath: 'assets/images/onboarding_features.png',
    ),
    const OnboardingContent(
      title: 'Dữ liệu an toàn',
      description:
          'Tất cả dữ liệu của bạn được lưu trữ cục bộ trên thiết bị, đảm bảo bảo mật tuyệt đối. Bạn có toàn quyền kiểm soát dữ liệu: xuất backup khi cần thiết hoặc xóa hoàn toàn bất cứ lúc nào.',
      imagePath: 'assets/images/onboarding_data.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed
    final onboardingService = ref.read(onboardingServiceProvider);
    await onboardingService.completeOnboarding();

    // Navigate to login
    if (mounted) {
      appRouter.goToLogin();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Bỏ qua',
                    style: theme.textRegular14Default.copyWith(
                      color: theme.colorTextSubtle,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingContentWidget(
                    content: _onboardingData[index],
                  );
                },
              ),
            ),

            // Bottom section with indicators and navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildIndicator(index, theme),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    children: [
                      // Previous button
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorPrimary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Quay lại',
                              style: theme.buttonSemibold14.copyWith(
                                color: theme.colorPrimary,
                              ),
                            ),
                          ),
                        ),

                      if (_currentPage > 0) const SizedBox(width: 16),

                      // Next/Complete button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1 ? 'Bắt đầu' : 'Tiếp theo',
                            style: theme.buttonSemibold14.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, AppThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? theme.colorPrimary : theme.colorPrimary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

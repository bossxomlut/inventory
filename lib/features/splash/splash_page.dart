import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/persistence/isar_storage.dart';
import '../../domain/repositories/auth/auth_repository.dart';
import '../../provider/index.dart';
import '../../resources/index.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';
import '../onboarding/onboarding_service.dart';

@RoutePage()
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    useEffect(() {
      // Initialize app and check onboarding/auth flow
      _initializeApp(ref);
      return null; // No cleanup needed
    }, []);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: AppImage.asset(
                url: ImagePath.logo,
                width: 200,
                height: 200,
              ),
            ),
            //Chào mừng bạn quay trờ lại
            Text(
              'Chào mừng bạn quay trở lại',
              style: theme.textMedium16Default,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Đang tải...',
              style: theme.textRegular13Subtle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeApp(WidgetRef ref) async {
    try {
      // Initialize database and storage in parallel
      await Future.wait([
        IsarDatabase().initialize(),
        ref.read(storageInitializerProvider.future),
      ]);

      // Create default admin if not exists
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.createDefaultAdmin();

      // Check if user has seen onboarding
      final onboardingService = ref.read(onboardingServiceProvider);
      final hasSeenOnboarding = await onboardingService.hasSeenOnboarding();

      if (!hasSeenOnboarding) {
        // Navigate to onboarding
        appRouter.goToOnboarding();
      } else {
        // Check authentication state as before
        ref.read(authControllerProvider.notifier).checkLogin();
      }
    } catch (e) {
      // Handle initialization error
      // Fall back to normal auth flow
      ref.read(authControllerProvider.notifier).checkLogin();
    }
  }
}

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/storage_provider.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  final Ref _ref;

  OnboardingService(this._ref);

  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    final storage = await _ref.read(initializedSimpleStorageProvider.future);
    return await storage.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final storage = await _ref.read(initializedSimpleStorageProvider.future);
    await storage.saveBool(_hasSeenOnboardingKey, true);
  }

  /// Reset onboarding state (for testing/debug)
  Future<void> resetOnboarding() async {
    final storage = await _ref.read(initializedSimpleStorageProvider.future);
    await storage.remove(_hasSeenOnboardingKey);
  }
}

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref);
});

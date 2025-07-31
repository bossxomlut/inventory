import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/persistence/key_value_storage.dart';
import '../../provider/storage_provider.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  OnboardingService(this._storage);

  final KeyValueStorage _storage;

  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    return await _storage.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _storage.saveBool(_hasSeenOnboardingKey, true);
  }

  /// Reset onboarding state (for testing/debug)
  Future<void> resetOnboarding() async {
    await _storage.remove(_hasSeenOnboardingKey);
  }
}

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref.read(simpleStorageProvider));
});

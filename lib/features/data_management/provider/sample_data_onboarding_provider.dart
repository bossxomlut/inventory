import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the sample-data flow is being shown as part of the
/// first-login onboarding for admins.
final sampleDataOnboardingProvider = StateProvider<bool>((ref) => false);

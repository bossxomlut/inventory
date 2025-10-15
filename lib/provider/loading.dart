// Provider used to manage a global loading indicator state.
import 'package:riverpod/riverpod.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

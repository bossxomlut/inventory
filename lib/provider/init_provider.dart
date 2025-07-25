import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider để theo dõi xem đã hiển thị dialog thông tin admin chưa
final hasShownAdminDialogProvider = StateNotifierProvider<HasShownAdminDialogNotifier, bool>((ref) {
  return HasShownAdminDialogNotifier();
});

class HasShownAdminDialogNotifier extends StateNotifier<bool> {
  HasShownAdminDialogNotifier() : super(false) {
    _loadDialogState();
  }

  static const String _keyHasShownAdminDialog = 'has_shown_admin_dialog';

  Future<void> _loadDialogState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyHasShownAdminDialog) ?? false;
  }

  Future<void> setDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasShownAdminDialog, true);
    state = true;
  }
}

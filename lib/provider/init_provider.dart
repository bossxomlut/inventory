import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/persistence/key_value_storage.dart';
import 'storage_provider.dart';

final hasShownAdminDialogServiceProvider = Provider<HasShownAdminDialogService>((ref) {
  return HasShownAdminDialogService(ref.read(simpleStorageProvider));
});

class HasShownAdminDialogService {
  HasShownAdminDialogService(this.storage);

  static const String _keyHasShownAdminDialog = 'has_shown_admin_dialog';

  final KeyValueStorage storage;

  Future<bool> checkNeedToShowDialog() async {
    return storage.getBool(_keyHasShownAdminDialog).then((bool? value) => !(value ?? false));
  }

  Future<void> setDialogShown() async {
    await storage.saveBool(_keyHasShownAdminDialog, true);
  }
}

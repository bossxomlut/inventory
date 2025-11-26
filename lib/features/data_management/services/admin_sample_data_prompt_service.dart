import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/persistence/key_value_storage.dart';
import '../../../domain/entities/user/user.dart';
import '../../../provider/storage_provider.dart';

final adminSampleDataPromptServiceProvider =
    Provider<AdminSampleDataPromptService>(
  (ref) => AdminSampleDataPromptService(ref.read(simpleStorageProvider)),
);

class AdminSampleDataPromptService {
  AdminSampleDataPromptService(this._storage);

  final KeyValueStorage _storage;
  static const String _keyPrefix = 'admin_sample_data_prompt_shown_';

  Future<bool> shouldShow(User user) async {
    if (user.role != UserRole.admin) {
      return false;
    }

    final hasSeen = await _storage.getBool(_keyForUser(user.id));
    return !(hasSeen ?? false);
  }

  Future<void> markCompleted(User user) async {
    if (user.role != UserRole.admin) {
      return;
    }

    await _storage.saveBool(_keyForUser(user.id), true);
  }

  String _keyForUser(int userId) => '$_keyPrefix$userId';
}

import 'package:in_app_review/in_app_review.dart';

import '../../core/persistence/key_value_storage.dart';

class InAppReviewUtil {
  InAppReviewUtil(this._storage);

  final InAppReview _inAppReview = InAppReview.instance;

  final KeyValueStorage _storage;

  static final String _isShowedKey = 'inAppReviewShowedKey';

  Future<void> checkAndShowReviewDialog() async {
    final bool isShowed = await _storage.getBool(_isShowedKey) ?? false;
    if (!isShowed) {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await _storage.saveBool(_isShowedKey, true);
      }
    }
  }

  Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  Future<void> openStoreListing() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.openStoreListing();
    }
  }

  Future<bool> isAvailable() async {
    return await _inAppReview.isAvailable();
  }
}

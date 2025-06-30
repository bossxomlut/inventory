import 'package:freezed_annotation/freezed_annotation.dart';

import 'checked_product.dart';

part 'check_session.freezed.dart';
part 'check_session.g.dart';

// Enum for inventory check session status
enum CheckSessionStatus {
  inProgress,
  completed,
}

// Inventory Check Session entity
@freezed
class CheckSession with _$CheckSession {
  const factory CheckSession({
    required int id,
    required String name,
    required DateTime startDate,
    DateTime? endDate,
    required String createdBy,
    required CheckSessionStatus status,
    @Default([]) List<CheckedProduct> checks,
    String? note,
  }) = _CheckSession;

  const CheckSession._();

  factory CheckSession.fromJson(Map<String, dynamic> json) => _$CheckSessionFromJson(json);

  // Computed properties
  bool get isCompleted => status == CheckSessionStatus.completed;
  bool get isInProgress => status == CheckSessionStatus.inProgress;

  int get totalProductsChecked => checks.length;
  int get discrepancyCount => checks.where((check) => check.hasDiscrepancy).length;

  Duration get duration {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }
}

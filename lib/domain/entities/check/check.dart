// Enum for inventory check session status
import '../../index.dart';

enum ActiveViewType { active, done }

enum CheckSessionStatus {
  draft,
  inProgress,
  completed,
  cancelled,
}

// Enum for inventory check status
enum CheckStatus {
  match, // Actual quantity matches expected
  surplus, // Actual quantity is higher than expected
  shortage, // Actual quantity is lower than expected
}

// Inventory Check Session entity
class CheckSession {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final String createdBy;
  final CheckSessionStatus status;
  final List<CheckedProduct> checks;
  final String? note;

  const CheckSession({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.createdBy,
    required this.status,
    required this.checks,
    this.note,
  });

  // Manual copyWith method (since we're not using Freezed to avoid code generation)
  CheckSession copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    CheckSessionStatus? status,
    List<CheckedProduct>? checks,
    String? note,
  }) {
    return CheckSession(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      checks: checks ?? this.checks,
      note: note ?? this.note,
    );
  }

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

// Individual Inventory Check entity
class CheckedProduct {
  final int id;
  final Product product;
  final int expectedQuantity;
  final int actualQuantity;
  final DateTime checkDate;
  final String checkedBy;
  final String? note;

  const CheckedProduct({
    required this.id,
    required this.product,
    required this.expectedQuantity,
    required this.actualQuantity,
    required this.checkDate,
    required this.checkedBy,
    this.note,
  });

  CheckedProduct copyWith({
    int? id,
    Product? product,
    int? expectedQuantity,
    int? actualQuantity,
    DateTime? checkDate,
    String? checkedBy,
    String? note,
  }) {
    return CheckedProduct(
      id: id ?? this.id,
      product: product ?? this.product,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      checkDate: checkDate ?? this.checkDate,
      checkedBy: checkedBy ?? this.checkedBy,
      note: note ?? this.note,
    );
  }

  String get productName => product.name;

  // Computed properties
  CheckStatus get status {
    if (actualQuantity == expectedQuantity) {
      return CheckStatus.match;
    } else if (actualQuantity > expectedQuantity) {
      return CheckStatus.surplus;
    } else {
      return CheckStatus.shortage;
    }
  }

  int get difference => actualQuantity - expectedQuantity;
  bool get hasDiscrepancy => actualQuantity != expectedQuantity;

  // Helper methods for UI display
  String get statusText {
    switch (status) {
      case CheckStatus.match:
        return 'Khớp';
      case CheckStatus.surplus:
        return 'Thừa';
      case CheckStatus.shortage:
        return 'Thiếu';
    }
  }

  String get differenceText {
    if (difference == 0) return 'Khớp';
    if (difference > 0) return '+$difference';
    return '$difference';
  }
}

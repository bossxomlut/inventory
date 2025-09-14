enum Difference {
  none,
  higher,
  lower,
  equal,
}

class DifferenceEntity {
  final Difference difference;
  final double percentage;

  DifferenceEntity({
    required this.difference,
    required this.percentage,
  });

  factory DifferenceEntity.empty() {
    return DifferenceEntity(
      difference: Difference.none,
      percentage: 0.0,
    );
  }
}

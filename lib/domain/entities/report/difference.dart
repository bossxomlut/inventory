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
}

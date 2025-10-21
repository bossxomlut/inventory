class ProductExpirySummary {
  const ProductExpirySummary({
    required this.totalTrackingProducts,
    required this.expiredProducts,
    required this.expiringSoonProducts,
    required this.soonThresholdDays,
  });

  final int totalTrackingProducts;
  final int expiredProducts;
  final int expiringSoonProducts;
  final int soonThresholdDays;
}

import 'package:flutter/material.dart';

import '../../../provider/index.dart';
import '../../../resources/index.dart';

const _expiryWarningColor = Color(0xFFFFA000);
const _defaultWarningThresholdDays = 7;

class ProductExpiryStatus {
  const ProductExpiryStatus({required this.text, required this.color});

  final String text;
  final Color color;
}

ProductExpiryStatus buildProductExpiryStatus({
  required BuildContext context,
  required int daysDifference,
  int warningThresholdDays = _defaultWarningThresholdDays,
}) {
  final theme = context.appTheme;

  if (daysDifference < 0) {
    return ProductExpiryStatus(
      text: LKey.productExpiryLabelExpired.tr(
        context: context,
        namedArgs: {'days': '${daysDifference.abs()}'},
      ),
      color: theme.colorTextSupportRed,
    );
  }

  if (daysDifference == 0) {
    return ProductExpiryStatus(
      text: LKey.productExpiryLabelToday.tr(context: context),
      color: theme.colorTextSupportRed,
    );
  }

  if (daysDifference <= warningThresholdDays) {
    return ProductExpiryStatus(
      text: LKey.productExpiryLabelDays.tr(
        context: context,
        namedArgs: {'days': '$daysDifference'},
      ),
      color: _expiryWarningColor,
    );
  }

  return ProductExpiryStatus(
    text: LKey.productExpiryLabelDays.tr(
      context: context,
      namedArgs: {'days': '$daysDifference'},
    ),
    color: theme.colorTextSupportGreen,
  );
}

class ProductExpiryStatusBadge extends StatelessWidget {
  const ProductExpiryStatusBadge({super.key, required this.status});

  final ProductExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withOpacity(0.24)),
      ),
      child: Text(
        status.text,
        style: theme.textRegular12Default.copyWith(color: status.color),
      ),
    );
  }
}

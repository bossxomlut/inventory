import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/entities/product/product_expiry_summary.dart';
import '../../../provider/index.dart';
import '../../../resources/index.dart';
import '../provider/product_expiry_summary_provider.dart';

class ProductExpirySummaryBanner extends ConsumerWidget {
  const ProductExpirySummaryBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;

    final summaryAsync = ref.watch(productExpirySummaryProvider);
    return summaryAsync.when(
      data: (summary) {
        if (summary.expiredProducts == 0 && summary.expiringSoonProducts == 0) {
          return const SizedBox.shrink();
        }

        final cards = <Widget>[];
        if (summary.expiredProducts > 0) {
          cards.add(
            _ExpiryStatTile(
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.redAccent,
              title: LKey.productExpirySummaryExpired.tr(
                context: context,
                namedArgs: {'count': '${summary.expiredProducts}'},
              ),
              subtitle:
                  LKey.productExpirySummaryActionRequired.tr(context: context),
            ),
          );
        }

        if (summary.expiringSoonProducts > 0) {
          cards.add(
            _ExpiryStatTile(
              icon: Icons.schedule,
              iconColor: Colors.orange,
              title: LKey.productExpirySummaryExpiringSoon.tr(
                context: context,
                namedArgs: {'count': '${summary.expiringSoonProducts}'},
              ),
              subtitle: LKey.productExpirySummaryDaysHint.tr(
                context: context,
                namedArgs: {'days': '${summary.soonThresholdDays}'},
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LKey.productExpirySummaryTitle.tr(context: context),
                style: theme.textMedium15Default.copyWith(
                  color: theme.colorTextDefault,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...cards.map((card) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: card,
                  )),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ExpiryStatTile extends StatelessWidget {
  const _ExpiryStatTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textMedium15Default.copyWith(
                    color: iconColor.darken(),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textRegular13Subtle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

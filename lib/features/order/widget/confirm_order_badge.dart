import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../home/providers/confirmed_orders_count_provider.dart';


class ConfirmOrderBadge extends ConsumerWidget {
  const ConfirmOrderBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeAsync = ref.watch(confirmedOrdersCountProvider);

    return badgeAsync.when(
      data: (count) {
        if (count <= 0) return const SizedBox.shrink();
        return Badge(
          backgroundColor: Colors.redAccent,
          label: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

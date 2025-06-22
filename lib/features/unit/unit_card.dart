import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_app/features/unit/provider/unit_filter_provider.dart';

import '../../core/index.dart';
import '../../domain/index.dart';
import '../../provider/index.dart';
import 'add_unit.dart';
import 'provider/unit_provider.dart';

class UnitCard extends StatelessWidget {
  const UnitCard({
    super.key,
    required this.unit,
    this.color,
    this.onTap,
  });

  final Unit unit;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return ListTile(
      minTileHeight: 68,
      leading: CircleAvatar(
        backgroundColor: unit.name.backgroundColorFromString,
        child: Text(
          unit.name.twoFirstLetters,
          style: theme.textMedium15Default.copyWith(
            color: unit.name.colorTextStyle,
          ),
        ),
      ),
      title: Text(unit.name, style: theme.textMedium16Default),
      subtitle: unit.description.isNullOrEmpty ? null : Text(unit.description ?? '', style: theme.textRegular14Subtle),
      onTap: onTap,
      tileColor: color,
    );
  }
}

class OptimizedUnitCard extends ConsumerWidget {
  const OptimizedUnitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.read(currentIndexProvider);
    final unit = ref.watch(currentUnitProvider);

    return Stack(
      children: [
        UnitCard(
          unit: unit,
          color: index.color,
          onTap: () {
            AddUnit(unit: unit).show(context);
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final enable = ref.watch(multiSelectUnitProvider.select((value) => value.enable));
              if (!enable) {
                return const SizedBox.shrink();
              }

              return Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final isSelected = ref.watch(multiSelectUnitProvider.select((value) => value.data.contains(unit)));
                  return Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      ref.read(multiSelectUnitProvider.notifier).toggle(unit);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

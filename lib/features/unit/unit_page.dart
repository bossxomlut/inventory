import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/index.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/index.dart';
import 'add_unit.dart';
import 'unit_card.dart';
import 'provider/unit_provider.dart';
import 'provider/unit_filter_provider.dart';

@RoutePage()
class UnitPage extends HookConsumerWidget {
  const UnitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void initData() {
      ref.read(unitProvider.notifier).refresh();
    }

    useEffect(() {
      Future(initData);
    }, const []);

    final units = ref.watch(unitProvider);

    final theme = context.appTheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final multiState = ref.watch(multiSelectUnitProvider);
            final enable = multiState.enable;
            final isNotEmpty = multiState.data.isNotEmpty;

            return CustomAppBar(
              title: 'Units',
              leading: enable
                  ? IconButton(
                      onPressed: () {
                        ref.read(multiSelectUnitProvider.notifier).disableAndClear();
                      },
                      icon: Icon(Icons.close, color: Colors.white, size: 24.0),
                    )
                  : AppBackButton(),
              actions: [
                if (enable)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                    ),
                    color: Colors.white,
                    onPressed: isNotEmpty
                        ? () {
                            ref.read(unitProvider.notifier).removeMultipleUnits();
                          }
                        : null,
                  ),
                if (!enable)
                  IconButton(
                    icon: Text(
                      'Choose',
                      style: theme.textMedium13Default.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (enable) {
                        ref.read(multiSelectUnitProvider.notifier).disable();
                      } else {
                        ref.read(multiSelectUnitProvider.notifier).enable();
                      }
                    },
                  ),
              ],
            );
          },
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (units.hasError) {
            return Center(child: Text('Error: ${units.error}'));
          } else if (units.data.isEmpty) {
            return const Center(child: Text('No units found.'));
          }

          return ListView.builder(
            itemCount: units.data.length,
            itemBuilder: (context, index) {
              return ProviderScope(
                overrides: [
                  currentIndexProvider.overrideWithValue(index),
                  currentUnitProvider.overrideWithValue(units.data[index]),
                ],
                child: const OptimizedUnitCard(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddUnit().show(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

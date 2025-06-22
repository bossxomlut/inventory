import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/index.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../provider/index.dart';
import '../../shared_widgets/index.dart';
import 'add_unit.dart';
import 'provider/unit_provider.dart';
import 'unit_card.dart';

class SelectUnitWidget extends HookConsumerWidget {
  const SelectUnitWidget({
    super.key,
    required this.onSelected,
  });

  final void Function(Unit unit) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocus = useFocusNode();
    final isSearching = useState(false);

    // Setup providers
    final unitLoadProvider = ref.watch(loadUnitProvider);

    useEffect(() {
      // Load units when the widget is first built
      ref.read(loadUnitProvider.notifier).init();
      return null;
    }, []);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chọn đơn vị',
        titleWidget: isSearching.value
            ? TextField(
                controller: searchController,
                focusNode: searchFocus,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm đơn vị...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(loadUnitProvider.notifier).search(value);
                },
              )
            : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching.value ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              isSearching.value = !isSearching.value;
              if (isSearching.value) {
                searchFocus.requestFocus();
              } else {
                searchController.clear();
                ref.read(loadUnitProvider.notifier).refresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (unitLoadProvider.isLoading && !unitLoadProvider.isLoadingMore) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (unitLoadProvider.error != null) {
                  return Center(child: Text('Lỗi: ${unitLoadProvider.error}'));
                }

                if (unitLoadProvider.data.isEmpty) {
                  return const Center(child: Text('Không có đơn vị nào'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: unitLoadProvider.data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final unit = unitLoadProvider.data[index];
                    return UnitCard(
                      unit: unit,
                      onTap: () => onSelected(unit),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showUnit(
  BuildContext context, {
  required void Function(Unit unit) onSelected,
}) {
  SearchItemWidget<Unit>(
    itemBuilder: (BuildContext context, Unit unit, int index) {
      return UnitCard(
        unit: unit,
        onTap: () {
          onSelected(unit);
        },
      );
    },
    onAddItem: () {
      AddUnit().show(context).then(
        (Unit? value) {
          if (value != null) {
            onSelected(value);
          }
        },
      );
    },
    searchItems: (String keyword) async {
      return context.read(unitRepositoryProvider).searchAll(keyword);
    },
  ).show(context);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/index.dart';
import '../../domain/index.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../provider/index.dart';
import '../../shared_widgets/index.dart';
import 'add_category.dart';
import 'category_card.dart';

void showCategory(
  BuildContext context, {
  ValueChanged<Category>? onSelected,
}) {
  final container = ProviderScope.containerOf(context, listen: false);
  final permissionsAsync = container.read(currentUserPermissionsProvider);
  final bool canCreate = permissionsAsync.maybeWhen(
    data: (value) => value.contains(PermissionKey.categoryCreate),
    orElse: () => false,
  );

  SearchItemWidget<Category>(
    itemBuilder: (BuildContext item, Category p1, int p2) {
      return CategoryCard(
        category: p1,
        color: p2.color,
        onTap: () {
          onSelected?.call(p1);
        },
      );
    },
    onAddItem: canCreate
        ? () {
            AddCategory().show(context).then(
              (Category? value) {
                if (value != null) {
                  onSelected?.call(value);
                }
              },
            );
          }
        : null,
    searchItems: (String keyword, int page, int size) async {
      final repository = container.read(categoryRepositoryProvider);
      final result = await repository.search(keyword, page, size);
      return result.data;
    },
    enableLoadMore: false,
  ).show(context);
}

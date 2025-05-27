import 'package:flutter/material.dart';

import '../../core/index.dart';
import '../../domain/index.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../provider/index.dart';
import '../../shared_widgets/index.dart';
import 'add_category.dart';
import 'category_card.dart';

void showCategory(
  BuildContext context, {
  ValueChanged<Category>? onSelected,
}) {
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
    onAddItem: () {
      AddCategory().show(context);
    },
    searchItems: (String keyword) async {
      return context.read(categoryRepositoryProvider).search(keyword, 0, 1000);
    },
  ).show(context);
}

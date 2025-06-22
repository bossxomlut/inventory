import 'package:flutter/material.dart';

import '../../domain/entities/unit/unit.dart';
import '../../features/product/widget/add_product_widget.dart';
import 'select_unit_widget.dart';

class AddUnitPlaceHolder extends CommonAddPlaceHolder<Unit> {
  AddUnitPlaceHolder({
    super.key,
    Unit? value,
    ValueChanged<Unit?>? onSelected,
  }) : super(
          onSelected: onSelected,
          onTap: (context) {
            showUnit(
              context,
              onSelected: (Unit value) {
                Navigator.pop(context);
                onSelected?.call(value);
              },
            );
          },
          value: value,
          getName: (Unit? value) => value?.name ?? '',
          title: 'Thêm đơn vị',
        );
}

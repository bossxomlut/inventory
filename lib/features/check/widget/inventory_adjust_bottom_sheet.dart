import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/index.dart';
import '../../../domain/index.dart';
import '../../../provider/index.dart';
import '../../../shared_widgets/index.dart';
import '../../product/widget/index.dart';

class InventoryAdjustBottomSheet extends HookWidget with ShowBottomSheet {
  const InventoryAdjustBottomSheet({
    super.key,
    required this.product,
    required this.onSave,
    this.currentQuantity,
    this.note,
  });
  final Product product;
  final int? currentQuantity;
  final String? note;
  final void Function(int quantity, [String? note]) onSave;

  @override
  Widget build(BuildContext context) {
    final noteController = useTextEditingController(text: note);
    final quantity = useState(currentQuantity ?? product.quantity);
    final theme = context.appTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomProductCard(
                product: product,
                subtitleWidget: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.colorSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Số lượng hệ thống: ${product.quantity.displayFormat()}',
                    style: theme.textMedium14Default,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const AppDivider(),
              const SizedBox(height: 12),
              TitleBlockWidget(
                title: 'Số lượng kiểm kê:',
                child: PlusMinusInputView(
                  initialValue: quantity.value,
                  minValue: 0,
                  onChanged: (val) => quantity.value = val,
                ),
              ),
              const SizedBox(height: 12),
              TitleBlockWidget(
                title: 'Ghi chú',
                child: CustomTextField(
                  controller: noteController,
                  label: 'Ghi chú',
                ),
              ),
            ],
          ),
        ),
        BottomButtonBar(
          onSave: () {
            onSave(quantity.value, noteController.text);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

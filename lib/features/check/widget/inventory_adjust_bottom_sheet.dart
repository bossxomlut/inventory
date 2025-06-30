import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../domain/index.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomProductCard(product: product),
          const SizedBox(height: 12),
          const AppDivider(),
          const SizedBox(height: 12),
          Text('Số lượng hệ thống: ${product.quantity}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Số lượng kiểm kê:', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 12),
              Expanded(
                child: PlusMinusInputView(
                  initialValue: quantity.value,
                  minValue: 0,
                  onChanged: (val) => quantity.value = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tuỳ chọn)',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  onSave(quantity.value, noteController.text);
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/index.dart';
import '../../../shared_widgets/index.dart';
import '../../product/widget/index.dart';

class InventoryAdjustBottomSheet extends StatefulWidget with ShowBottomSheet {
  const InventoryAdjustBottomSheet({super.key, required this.product, required this.onSave});
  final Product product;
  final void Function(int quantity, [String? note]) onSave;

  @override
  State<InventoryAdjustBottomSheet> createState() => _InventoryAdjustBottomSheetState();
}

class _InventoryAdjustBottomSheetState extends State<InventoryAdjustBottomSheet> {
  late int quantity;
  final TextEditingController noteController = TextEditingController();

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    quantity = widget.product.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductCard(product: product),
          const SizedBox(height: 12),
          Text('Số lượng trong kho: ${widget.product.quantity}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Số lượng kiểm kê:', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 12),
              Expanded(
                child: PlusMinusInputView(
                  initialValue: quantity,
                  minValue: 0,
                  onChanged: (val) => setState(() => quantity = val),
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
                  widget.onSave(quantity, noteController.text);
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

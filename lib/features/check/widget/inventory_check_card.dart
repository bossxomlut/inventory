import 'package:flutter/material.dart';

import '../../../domain/entities/check/checked_product.dart';
import '../../../domain/entities/product/inventory.dart';

class InventoryCheckCard extends StatelessWidget {
  final CheckedProduct check;
  final VoidCallback? onTap;

  const InventoryCheckCard({
    super.key,
    required this.check,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      check.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: check.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QuantityInfo(
                    label: 'Hệ thống',
                    quantity: check.expectedQuantity,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _QuantityInfo(
                    label: 'Kiểm kê',
                    quantity: check.actualQuantity,
                    color: _getQuantityColor(check.status),
                  ),
                  const SizedBox(width: 16),
                  if (check.hasDiscrepancy)
                    _QuantityInfo(
                      label: 'Chênh lệch',
                      quantity: check.difference,
                      color: check.difference > 0 ? Colors.green : Colors.red,
                      showSign: true,
                    ),
                ],
              ),
              if (check.note?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  'Ghi chú: ${check.note}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Kiểm kê: ${_formatDate(check.checkDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQuantityColor(CheckStatus status) {
    switch (status) {
      case CheckStatus.match:
        return Colors.green;
      case CheckStatus.surplus:
        return Colors.orange;
      case CheckStatus.shortage:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final CheckStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  (String, Color) _getStatusInfo(CheckStatus status) {
    switch (status) {
      case CheckStatus.match:
        return ('Khớp', Colors.green);
      case CheckStatus.surplus:
        return ('Thừa', Colors.orange);
      case CheckStatus.shortage:
        return ('Thiếu', Colors.red);
    }
  }
}

class _QuantityInfo extends StatelessWidget {
  final String label;
  final int quantity;
  final Color color;
  final bool showSign;

  const _QuantityInfo({
    required this.label,
    required this.quantity,
    required this.color,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '${showSign && quantity > 0 ? '+' : ''}$quantity',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

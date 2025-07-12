import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../provider/theme.dart';
import '../../../domain/models/sample_product.dart';

class SampleProductCard extends StatelessWidget {
  final SampleProduct product;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;

  const SampleProductCard({
    super.key,
    required this.product,
    required this.isSelected,
    this.onTap,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: isSelected ? 3 : 1,
        shadowColor: isSelected ? theme.colorPrimary.withOpacity(0.3) : null,
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                ? Border.all(color: theme.colorPrimary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Checkbox(
                  value: isSelected,
                  onChanged: onCheckboxChanged,
                  activeColor: theme.colorPrimary,
                ),
                const SizedBox(width: 8),
                
                // Product Image Placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey[50],
                    border: Border.all(color: theme.colorBorderField),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedImageNotFound01,
                    color: theme.colorIcon,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: theme.textMedium16Default,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // SKU (if available)
                      if (product.barcode?.isNotEmpty == true) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 14,
                              color: theme.colorIcon,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SKU: ${product.barcode!}',
                              style: theme.textRegular12Default,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      
                      // Category
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 14,
                            color: theme.colorIcon,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.categoryName,
                            style: theme.textRegular14Default,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Unit
                      Row(
                        children: [
                          Icon(
                            Icons.straighten,
                            size: 14,
                            color: theme.colorIcon,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.unitName,
                            style: theme.textRegular14Default,
                          ),
                        ],
                      ),
                      
                      // Description
                      if (product.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 6),
                        Text(
                          product.description!,
                          style: theme.textRegular12Default,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Price
                      Text(
                        'Giá bán: ${product.price.toStringAsFixed(0)}đ',
                        style: TextStyle(
                          color: theme.colorPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Right side - Quantity only
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.colorBorderField),
                  ),
                  child: Text(
                    'SL: ${product.quantity}',
                    style: theme.textRegular14Default,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

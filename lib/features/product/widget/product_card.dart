import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../../domain/index.dart';
import '../../../provider/index.dart';

const double productImageSize = 56;

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap; // Callback khi nhấn vào card

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final firstImage = (product.images != null && product.images!.isNotEmpty && product.images!.first.path != null)
        ? product.images!.first.path
        : null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2), // Đổ bóng nhẹ
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-image-${product.id}',
              child: firstImage != null
                  ? Container(
                      width: productImageSize,
                      height: productImageSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: theme.colorBackground,
                        border: Border.all(color: theme.colorBorderField),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(firstImage),
                          width: productImageSize,
                          height: productImageSize,
                          cacheHeight: 280,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: productImageSize,
                            height: productImageSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: theme.colorBackground,
                              border: Border.all(color: theme.colorBorderField),
                            ),
                            child: Icon(
                              HugeIcons.strokeRoundedImageNotFound02,
                              color: theme.colorIcon,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: productImageSize,
                      height: productImageSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: theme.colorBackground,
                        border: Border.all(color: theme.colorBorderField),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedImageNotFound01,
                        color: theme.colorIcon,
                        size: 28,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hiển thị loại sản phẩm
                          const SizedBox(height: 4),
                          BarcodeInfoWidget(barcode: product.barcode),
                          if (product.unit != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.straighten,
                                    size: 16,
                                    color: context.appTheme.colorIcon,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    product.unit!.name,
                                    style: context.appTheme.textRegular14Default,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )),
                      // Hiển thị số lượng tồn kho
                      QuantityWidget(quantity: product.quantity),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder khi không có ảnh
  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}

//// Vertical product card with image on top
class VerticalProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const VerticalProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final firstImage = (product.images != null && product.images!.isNotEmpty && product.images!.first.path != null)
        ? product.images!.first.path
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'vertical-product-image-${product.id}',
              child: firstImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(firstImage),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: theme.colorBackground,
                            border: Border.all(color: theme.colorBorderField),
                          ),
                          child: Icon(
                            HugeIcons.strokeRoundedImageNotFound02,
                            color: theme.colorIcon,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: theme.colorBackground,
                        border: Border.all(color: theme.colorBorderField),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedImageNotFound01,
                        color: theme.colorIcon,
                        size: 32,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            BarcodeInfoWidget(barcode: product.barcode),
            if (product.unit != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  product.unit!.name,
                  style: theme.textRegular14Default,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            QuantityWidget(quantity: product.quantity),
          ],
        ),
      ),
    );
  }
}

class BarcodeInfoWidget extends StatelessWidget {
  const BarcodeInfoWidget({super.key, this.barcode});

  final String? barcode;

  @override
  Widget build(BuildContext context) {
    if (barcode == null || barcode!.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị nếu không có mã vạch
    }
    final theme = context.appTheme;
    return Row(
      children: [
        Icon(
          Icons.qr_code,
          size: 16,
          color: theme.colorIcon,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            barcode!,
            style: theme.textRegular14Default,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class QuantityWidget extends StatelessWidget {
  const QuantityWidget({super.key, required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 56,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.appTheme.colorBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appTheme.colorBorderField),
      ),
      alignment: Alignment.center,
      child: Text(
        'SL: ${quantity}',
        style: context.appTheme.textRegular14Default,
      ),
    );
  }
}

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
              child: _ProductImage(imagePath: firstImage),
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
}

class CustomProductCard extends StatelessWidget {
  const CustomProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.bottomWidget,
    this.subtitleWidget,
    this.trailingWidget,
  });

  final Product product;
  final VoidCallback? onTap;
  final Widget? subtitleWidget;
  final Widget? bottomWidget;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final firstImage = (product.images != null && product.images!.isNotEmpty && product.images!.first.path != null)
        ? product.images!.first.path
        : null;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(
                imagePath: firstImage,
                size: 40,
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
                      style: theme.textMedium16Default,
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
                                      color: theme.colorIcon,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      product.unit!.name,
                                      style: theme.textRegular14Default,
                                    ),
                                  ],
                                ),
                              ),
                            //subtitle widget
                            if (subtitleWidget != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: subtitleWidget!,
                              ),
                          ],
                        )),
                      ],
                    )
                  ],
                ),
              ),
              //trailing widget
              if (trailingWidget != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: trailingWidget!,
                ),
            ],
          ),
          if (bottomWidget != null) const SizedBox(height: 8),
          if (bottomWidget != null) bottomWidget!,
        ],
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
            _ProductImage(imagePath: firstImage),
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
      // alignment: Alignment.center,
      child: Text(
        'SL: ${quantity}',
        style: context.appTheme.textRegular14Default,
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({super.key, this.imagePath, this.size = productImageSize});

  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return imagePath != null
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: theme.colorBackground,
              border: Border.all(color: theme.colorBorderField),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(imagePath!),
                width: size,
                height: size,
                cacheHeight: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: size,
                  height: size,
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
            width: size,
            height: size,
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
          );
  }
}

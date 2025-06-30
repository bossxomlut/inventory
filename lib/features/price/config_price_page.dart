import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/index.dart';
import '../../domain/entities/get_id.dart';
import '../../domain/entities/order/price.dart';
import '../../domain/entities/product/inventory.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/index.dart';
import '../product/product_list_page.dart';
import '../product/provider/product_provider.dart';
import '../product/widget/product_card.dart';

@RoutePage()
class ConfigProductPricePage extends HookConsumerWidget {
  const ConfigProductPricePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cấu hình giá sản phẩm'),
        actions: [],
      ),
      body: const Column(
        children: [
          Expanded(child: ProductListView()),
        ],
      ),
    );
  }
}

class ProductListView extends HookConsumerWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use loadProductProvider directly
    final products = ref.watch(loadProductProvider);

    if (products.hasError) {
      return Center(child: Text('Error: ${products.error}'));
    } else if (products.isEmpty) {
      return const EmptyItemWidget();
    } else {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text('Đã tải ${products.data.length}/${products.totalCount} sản phẩm'),
          ),
          Expanded(
            child: LoadMoreList<Product>(
              items: products.data,
              itemBuilder: (context, index) {
                final product = products.data[index];
                return Consumer(builder: (context, ref, child) {
                  // Fetch product price by product ID
                  final productPrice = ref.watch(productPriceByIdProvider(product.id));
                  return GestureDetector(
                    onTap: () {
                      CreateProductPriceBottomSheet(
                        product: product,
                        productPrice: productPrice.valueOrNull,
                      ).show(context);
                    },
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomProductCard(
                                product: product,
                              ),
                            ),
                            const SizedBox(width: 8),
                            //product price here
                            productPrice.when(
                              data: (price) => Text(
                                'Giá bán: ${price.sellingPrice?.priceFormat()}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              loading: () => const SizedBox(),
                              error: (error, stack) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
              separatorBuilder: (context, index) => const AppDivider(),
              onLoadMore: () async {
                print('Loading more products...');
                return Future(
                  () {
                    return ref.read(loadProductProvider.notifier).loadMore();
                  },
                );
              },
              isCanLoadMore: !products.isEndOfList,
            ),
          ),
        ],
      );
    }
  }
}

//create product price bottom sheet
class CreateProductPriceBottomSheet extends HookConsumerWidget with ShowBottomSheet {
  final Product product;
  final ProductPrice? productPrice;

  const CreateProductPriceBottomSheet({
    super.key,
    required this.product,
    this.productPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellPriceController = useTextEditingController();
    final purchasePriceController = useTextEditingController();

    double? sellingPrice() {
      return double.tryParse(sellPriceController.text);
    }

    double? purchasePrice() {
      return double.tryParse(purchasePriceController.text);
    }

    useEffect(() {
      if (productPrice != null) {
        sellPriceController.text = productPrice!.sellingPrice?.inputFormat() ?? '';
        purchasePriceController.text = productPrice!.purchasePrice?.inputFormat() ?? '';
      }
    }, [productPrice]);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProductCard(product: product),
          const SizedBox(height: 16),
          //Gía bán
          TextField(
            controller: sellPriceController,
            decoration: const InputDecoration(
              labelText: 'Giá bán',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          //Gía vốn
          TextField(
            controller: purchasePriceController,
            decoration: const InputDecoration(
              labelText: 'Giá mua',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          // Add your form fields here
          ElevatedButton(
            onPressed: () async {
              final priceRepository = ref.read(priceRepositoryProvider);
              if (productPrice != null) {
                // Update existing price
                await priceRepository.update(
                  productPrice!.copyWith(
                    sellingPrice: sellingPrice(), // Replace with actual value
                    purchasePrice: purchasePrice(), // Replace with actual value
                  ),
                );
              } else {
                // Create new price
                await priceRepository.create(
                  ProductPrice(
                    id: undefinedId,
                    productName: product.name,
                    productId: product.id,
                    sellingPrice: sellingPrice(), // Replace with actual value
                    purchasePrice: purchasePrice(), // Replace with actual value
                  ),
                );
              }

              ref.invalidate(productPriceByIdProvider(product.id));
              // Handle save action
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

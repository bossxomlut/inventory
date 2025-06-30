import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/helpers/scaffold_utils.dart';
import '../../domain/index.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../shared_widgets/block/title_block_widget.dart';
import '../../shared_widgets/search/search_item_widget.dart';
import '../product/widget/index.dart';
import 'provider/order_provider.dart';

@RoutePage()
class CreateOrderPage extends HookConsumerWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStaste = ref.watch(orderCreationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //danh sách sản phẩm
            TitleBlockWidget(title: 'Sản phẩm', child: Column()),
            Column(
              children: [
                ...orderStaste.orders.map(
                  (orderItem) => OrderItemWidget(
                    product: orderItem.product,
                    orderItem: orderItem,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            //Khách hàng

            //Thanh toán
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SearchItemWidget<Product>(
            itemBuilder: (context, product, index) {
              return Consumer(builder: (context, ref, child) {
                final productPrice = ref.watch(productPriceByIdProvider(product.id));

                final OrderItem? orderItem = ref.watch(orderCreationProvider.select(
                  (OrderState value) => value.orders.firstWhereOrNull(
                    (item) => item.product.id == product.id,
                  ),
                ));

                final isSelected = orderItem != null;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      //Check Box để chọn sản phẩm
                      Checkbox(
                        value: isSelected, // This should be managed by state
                        onChanged: (value) {
                          print('Checkbox changed: $value for product ${product.name}');
                          // Handle checkbox state change
                          if (value == true) {
                            // Thêm sản phẩm vào đơn hàng
                            ref.read(orderCreationProvider.notifier).addOrderItem(
                                  OrderItem(
                                    quantity: 1, // Mặc định số lượng là 1
                                    price: productPrice.value!.sellingPrice!, // Sử dụng giá của sản phẩm
                                    product: product,
                                  ),
                                );
                          } else {
                            //remove sản phẩm khỏi đơn hàng
                            final index = orderItem!.product.id;
                            ref.read(orderCreationProvider.notifier).remove(orderItem);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrderItemWidget(
                          product: product,
                          orderItem: orderItem,
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
            searchItems: (keyword) async {
              final searchProductRepo = ref.read(searchProductRepositoryProvider);
              final products = await searchProductRepo.search(keyword, 1, 20);
              return products.data;
            },
          ).show(context);
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

//create a plus/minus button widget
class PlusMinusButton extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PlusMinusButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (value > 0) {
              onChanged(value - 1);
            }
          },
        ),
        Text(value.toString()),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            onChanged(value + 1);
          },
        ),
      ],
    );
  }
}

class OrderItemWidget extends HookConsumerWidget {
  const OrderItemWidget({super.key, required this.product, this.orderItem});

  final Product product;
  final OrderItem? orderItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = orderItem != null;
    final productPrice = ref.watch(productPriceByIdProvider(product.id));

    return Row(
      children: [
        Expanded(
          child: CustomProductCard(
            product: product,
            subtitleWidget: productPrice.when(
              data: (price) => Text(
                'Giá bán: ${price.sellingPrice?.priceFormat()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              loading: () => SizedBox(),
              error: (error, stack) => SizedBox(),
            ),
          ),
        ),
        if (isSelected)
          PlusMinusButton(
            value: orderItem!.quantity,
            onChanged: (int value) {
              ref.read(orderCreationProvider.notifier).updateOrderItem2(
                    orderItem!.copyWith(quantity: value),
                  );
            },
          ),
      ],
    );
  }
}

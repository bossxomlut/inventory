import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/helpers/scaffold_utils.dart';
import '../../domain/index.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../provider/index.dart';
import '../../shared_widgets/app_divider.dart';
import '../../shared_widgets/search/search_item_widget.dart';
import '../product/widget/index.dart';
import 'provider/order_provider.dart';

@RoutePage()
class CreateOrderPage extends HookConsumerWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStaste = ref.watch(orderCreationProvider);
    final theme = context.appTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //danh sách sản phẩm
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                'Sản phẩm',
                style: theme.textMedium16Default,
              ),
            ),
            ColoredBox(
              color: Colors.white,
              child: Column(
                children: [
                  ...orderStaste.orderItems.entries.map(
                    (entry) => OrderItemWidget(
                      product: entry.key,
                      orderItem: entry.value,
                    ),
                  )
                ],
              ),
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
              return OrderItemSelectionWidget(product: product);
            },
            searchItems: (keyword) async {
              final searchProductRepo = ref.read(searchProductRepositoryProvider);
              final products = await searchProductRepo.search(keyword, 1, 20);
              return products.data;
            },
            itemBuilderWithIndex: (BuildContext context, int index) => const AppDivider(),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //check box here
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  // Xử lý thay đổi trạng thái checkbox
                  if (value == false) {
                    // Nếu bỏ chọn, xóa sản phẩm khỏi đơn hàng
                    ref.read(orderCreationProvider.notifier).remove(product);
                  } else {
                    // Nếu chọn, thêm sản phẩm vào đơn hàng
                    ref.read(orderCreationProvider.notifier).addOrderItem(
                          product,
                          OrderItem(
                            quantity: 1, // Mặc định số lượng là 1
                            temporaryPrice: productPrice.valueOrNull?.sellingPrice ?? 0,
                          ),
                        );
                  }
                },
              ),

              if (isSelected)
                // Hiển thị số lượng và nút cộng trừ
                PlusMinusButton(
                  value: orderItem!.quantity,
                  onChanged: (int value) {
                    ref.read(orderCreationProvider.notifier).updateOrderItem(
                          product,
                          orderItem!.copyWith(quantity: value),
                        );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderItemSelectionWidget extends HookConsumerWidget {
  const OrderItemSelectionWidget({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OrderItem? orderItem = ref.watch(orderCreationProvider.select(
      (OrderState value) => value.orderItems[product],
    ));

    final theme = context.appTheme;

    return OrderItemWidget(
      product: product,
      orderItem: orderItem,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/helpers/format_utils.dart';
import '../../core/helpers/scaffold_utils.dart';
import '../../domain/index.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../provider/index.dart';
import '../../shared_widgets/app_bar.dart';
import '../../shared_widgets/app_divider.dart';
import '../../shared_widgets/button/bottom_button_bar.dart';
import '../../shared_widgets/button/plus_minus_input_view.dart';
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
      appBar: CustomAppBar(title: 'Tạo đơn'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //danh sách sản phẩm
            ColoredBox(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Text(
                      'Sản phẩm',
                      style: theme.textMedium16Default,
                    ),
                  ),
                  if (orderStaste.orderItems.isEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Chưa có sản phẩm nào trong đơn hàng',
                            style: theme.textRegular15Subtle,
                          ),
                        ),
                      ],
                    ),
                  ...orderStaste.orderItems.entries.map(
                    (entry) => OrderItemWidget(
                      product: entry.key,
                      orderItem: entry.value,
                    ),
                  ),
                  Row(
                    children: [
                      //add product button
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            showSelectOrderItem(context, ref);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add),
                              const SizedBox(width: 8),
                              Text(
                                'Thêm sản phẩm',
                                style: theme.textMedium15Default,
                              ),
                            ],
                          ),
                        ),
                      ),

                      //add product by scan
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            showSelectOrderItem(context, ref);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code),
                              const SizedBox(width: 8),
                              Text(
                                'Quét sản phẩm',
                                style: theme.textMedium15Default,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //Khách hàng
            ColoredBox(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Text(
                      'Thanh toán',
                      style: theme.textMedium16Default,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng số lượng',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          orderStaste.totalQuantity.displayFormat(),
                          style: theme.textRegular15Default,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng tiền',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          orderStaste.totalPrice.priceFormat(),
                          style: theme.textRegular15Default,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 100),

            //Thanh toán
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showSelectOrderItem(context, ref);
        },
        child: const Icon(Icons.search),
      ),
      bottomNavigationBar: BottomButtonBar(
        cancelButtonText: 'Lưu nháp',
        saveButtonText: 'Tạo đơn',
        onCancel: orderStaste.isNotEmpty
            ? () {
                ref.read(orderCreationProvider.notifier).saveDraft();
              }
            : null,
        onSave: orderStaste.isNotEmpty
            ? () {
                ref.read(orderCreationProvider.notifier).createOrder();
              }
            : null,
      ),
    );
  }
}

void showSelectOrderItem(BuildContext context, WidgetRef ref) {
  SearchItemWidget<Product>(
    itemBuilder: (context, product, index) {
      return OrderItemSelectionWidget(product: product);
    },
    searchItems: (keyword, page, size) async {
      final searchProductRepo = ref.read(searchProductRepositoryProvider);
      final products = await searchProductRepo.search(keyword, page, size);
      return products.data;
    },
    itemBuilderWithIndex: (BuildContext context, int index) => const AppDivider(),
  ).show(context);
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
                            id: undefinedId,
                            orderId: undefinedId,
                            productId: product.id,
                            productName: product.name,
                            quantity: 1, // Mặc định số lượng là 1
                            price: productPrice.valueOrNull?.sellingPrice ?? 0,
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

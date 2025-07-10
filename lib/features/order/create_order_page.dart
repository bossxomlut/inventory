import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_app/features/order/provider/order_list_provider.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/helpers/format_utils.dart';
import '../../domain/index.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../../domain/repositories/product/inventory_repository.dart';
import '../../provider/index.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import '../product/widget/index.dart';
import 'provider/order_provider.dart';

@RoutePage()
class CreateOrderPage extends HookConsumerWidget {
  const CreateOrderPage(this.order, {super.key});

  final Order? order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStaste = ref.watch(orderCreationProvider);
    final isKeyboardVisible = ref.watch(isKeyboardVisibleProvider);
    final theme = context.appTheme;
    final noteController = useTextEditingController();

    useEffect(() {
      // Set initial note if order is not null
      if (order != null) {
        ref.watch(orderCreationProvider.notifier).initializeOrder(order!);
      }
      return null;
    }, [order]);

    useEffect(() {
      noteController.text = orderStaste.order?.note ?? '';
      return null;
    }, [orderStaste.order?.note]);

    Widget buildBottomButtonBar() {
      return BottomButtonBar(
        cancelButtonText: 'Lưu nháp',
        saveButtonText: 'Tạo đơn',
        onCancel: orderStaste.isNotEmpty
            ? () {
                //set note
                ref.read(orderCreationProvider.notifier).setNote(noteController.text.trim());
                ref.read(orderCreationProvider.notifier).saveDraft();
              }
            : null,
        onSave: orderStaste.isNotEmpty
            ? () {
                ref.read(orderCreationProvider.notifier).setNote(noteController.text.trim());

                ref.read(orderCreationProvider.notifier).createOrder();
              }
            : null,
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Tạo đơn'),
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
                  //listView Separator
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderStaste.orderItems.length,
                    separatorBuilder: (context, index) => const AppDivider(),
                    itemBuilder: (context, index) {
                      final product = orderStaste.orderItems.keys.elementAt(index);
                      final orderItem = orderStaste.orderItems.values.elementAt(index);
                      return OrderItemWidget(
                        product: product,
                        orderItem: orderItem,
                      );
                    },
                  ),
                  const AppDivider(),
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
                            ScannerView.scanBarcodePage(
                              context,
                              onBarcodeScanned: (value) async {
                                //search product by barcode
                                try {
                                  final productRepo = ref.read(searchProductRepositoryProvider);
                                  final product = await productRepo.searchByBarcode(value.displayValue ?? '');
                                  final currentQuantity = ref
                                      .read(orderCreationProvider.select((state) => state.orderItems[product]))
                                      ?.quantity;

                                  await OrderNumberInputWidget(
                                    product: product,
                                    currentQuantity: currentQuantity,
                                    onSave: (quantity, price) {
                                      //add order item
                                      ref.read(orderCreationProvider.notifier).addOrderItem(
                                            product,
                                            OrderItem(
                                              id: undefinedId,
                                              orderId: undefinedId,
                                              productId: product.id,
                                              productName: product.name,
                                              quantity: quantity,
                                              price: price,
                                            ),
                                          );
                                      Navigator.pop(context); // Đóng bottom sheet sau khi thêm sản phẩm
                                    },
                                  ).show(context);
                                } catch (e) {
                                  showError(message: 'Không tìm thấy sản phẩm với mã vạch ${value.displayValue}');
                                }
                              },
                            );
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
                  InkWell(
                    onTap: () {
                      //show bottom sheet to select customer
                      CustomerInforWidget(
                        customerName: orderStaste.order?.customer,
                        customerContact: orderStaste.order?.customerContact,
                        onSave: (String name, String contact) {
                          ref.read(orderCreationProvider.notifier).setCustomerInfo(name, contact);
                        },
                      ).show(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Khách hàng',
                            style: theme.textMedium16Default,
                          ),
                          //icon next
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tên khách hàng',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          orderStaste.order?.customer ?? 'Chưa có',
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
                          'Liên hệ',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          orderStaste.order?.customerContact ?? 'Chưa có',
                          style: theme.textRegular15Default,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // Note
            const SizedBox(height: 10),
            ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ghi chú',
                      style: theme.textMedium16Default,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField.multiLines(
                      controller: noteController,
                      minLines: 1,
                      hint: 'Nhập ghi chú',
                    ),
                  ],
                ),
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

            isKeyboardVisible ? buildBottomButtonBar() : const SizedBox(height: 100),

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
      bottomNavigationBar: buildBottomButtonBar(),
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
    addItemWidget: Icon(
      Icons.close,
      size: 20,
      color: context.appTheme.colorIcon,
    ),
    onAddItem: () {
      Navigator.pop(context);
    },
    showAddButtonWhenEmpty: false,
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
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
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
              //Tồn
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Tồn: ${product.quantity.displayFormat()}'),
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

class CustomerInforWidget extends HookWidget with ShowBottomSheet {
  const CustomerInforWidget({super.key, this.customerName, this.customerContact, required this.onSave});
  final String? customerName;
  final String? customerContact;

  final Function(String name, String contact) onSave;

  @override
  Widget build(BuildContext context) {
    //controllers
    final nameController = useTextEditingController(text: customerName ?? '');
    final contactController = useTextEditingController(text: customerContact ?? '');
    final theme = context.appTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Thông tin khách hàng',
                style: theme.headingSemibold20Default,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 16),
          //Gía bán
          TitleBlockWidget(
            title: 'Tên khách hàng',
            child: CustomTextField(
              controller: nameController,
              label: 'Tên khách hàng',
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          //Giá vốn
          TitleBlockWidget(
            title: 'Liên hệ',
            child: CustomTextField(
              controller: contactController,
              label: 'Liên hệ',
              textInputAction: TextInputAction.done,
            ),
          ),

          // Add yo
          BottomButtonBar(
            padding: EdgeInsets.only(top: 16),
            onSave: () async {
              // Lấy thông tin từ các TextField và gọi onSave
              final name = nameController.text.trim();
              final contact = contactController.text.trim();
              if (name.isNotEmpty || contact.isNotEmpty) {
                Navigator.of(context).pop(); // Đóng bottom sheet
                onSave(name, contact);
              } else {
                showError(message: 'Vui lòng nhập thông tin khách hàng');
              }
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

@RoutePage()
class OrderDetailPage extends HookConsumerWidget {
  const OrderDetailPage({super.key, required this.order});

  final Order order;

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStaste = ref.watch(orderDetailProvider(order));
    final theme = context.appTheme;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Chi tiết đơn hàng'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColoredBox(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Order info
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Thông tin đơn hàng',
                            style: theme.textMedium16Default,
                          ),
                        ),
                        //order status tag here
                        const SizedBox(width: 8),
                        if (orderStaste.order != null)
                          OrderStatusTag(
                            status: orderStaste.order!.status,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mã đơn hàng',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          '#${orderStaste.order?.id.toString() ?? 'Chưa có'}',
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

                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tên khách hàng',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          orderStaste.order?.customer ?? 'Chưa có',
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
                          'Liên hệ',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          orderStaste.order?.customerContact ?? 'Chưa có',
                          style: theme.textRegular15Default,
                        ),
                      ],
                    ),
                  ),
                  // Note
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ghi chú',
                          style: theme.textRegular15Subtle,
                        ),
                        Text(
                          orderStaste.order?.note ?? '',
                          style: theme.textRegular15Default,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                  //listView Separator
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderStaste.orderItems.length,
                    separatorBuilder: (context, index) => const AppDivider(),
                    itemBuilder: (context, index) => _OrderItem(
                      product: orderStaste.orderItems.keys.elementAt(index),
                      orderItem: orderStaste.orderItems.values.elementAt(index),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            //Thanh toán
          ],
        ),
      ),
      bottomNavigationBar: buildBottomButtonBar(orderStaste.order, ref),
    );
  }

  Widget buildBottomButtonBar(Order? order, WidgetRef ref) {
    if (order == null) {
      return const SizedBox.shrink();
    }

    switch (order.status) {
      case OrderStatus.draft:
        return BottomButtonBar(
          saveButtonText: 'Tạo đơn',
          cancelButtonText: 'Chỉnh sửa',
          onSave: () async {
            ref.read(orderDetailProvider(order).notifier).createOrder();
            ref.invalidate(orderListProvider(order.status));
          },
          onCancel: () async {
            await appRouter.goToUpdateDraftOrder(order);
          },
        );
      case OrderStatus.confirmed:
        return BottomButtonBar(
          saveButtonText: 'Hoàn thành',
          cancelButtonText: 'Huỷ đơn',
          onSave: () {
            ref.read(orderListProvider(order.status).notifier).confirmOrder(order);
            ref.invalidate(orderDetailProvider(order));
          },
          onCancel: () {
            ref.read(orderListProvider(order.status).notifier).cancelOrder(order);
            ref.invalidate(orderDetailProvider(order));
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class OrderStatusTag extends StatelessWidget {
  const OrderStatusTag({super.key, required this.status, this.size = 20});

  final OrderStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: theme.textMedium16Default.copyWith(color: status.color),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({super.key, required this.product, this.orderItem});
  final Product product;
  final OrderItem? orderItem;
  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: CustomProductCard(
        product: product,
        trailingWidget: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            QuantityWidget(quantity: orderItem?.quantity ?? 0),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(
                minWidth: 56,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.appTheme.colorTextSupportRed.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.appTheme.colorBorderField),
              ),
              // alignment: Alignment.center,
              child: Text(
                'Giá: ${orderItem?.price.priceFormat() ?? '0'}',
                style: context.appTheme.textRegular14Default,
              ),
            ),
          ],
        ),
        bottomWidget: Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tổng: ${((orderItem?.price ?? 0) * (orderItem?.quantity ?? 0)).priceFormat()}',
                style: theme.textMedium15Default,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderNumberInputWidget extends HookConsumerWidget with ShowBottomSheet {
  const OrderNumberInputWidget({
    super.key,
    required this.product,
    required this.currentQuantity,
    required this.onSave,
  });

  final Product product;
  final int? currentQuantity;
  final Function(int quantity, double price) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = useState(currentQuantity ?? product.quantity);
    final productPrice = ref.watch(productPriceByIdProvider(product.id));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomProductCard(
            product: product,
            subtitleWidget: productPrice.when(
              data: (price) => Text(
                'Giá bán: ${price.sellingPrice?.priceFormat()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              loading: () => const SizedBox(),
              error: (error, stack) => const SizedBox(),
            ),
          ),
          const SizedBox(height: 12),
          const AppDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Số lượng đặt hàng:', style: TextStyle(fontSize: 16)),
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
                  onSave(quantity.value, productPrice.valueOrNull?.sellingPrice ?? 0);
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

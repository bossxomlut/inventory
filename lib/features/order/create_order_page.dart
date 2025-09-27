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
import 'provider/order_action_confirm_provider.dart';
import 'provider/order_action_handler.dart';
import 'provider/order_provider.dart';
import 'widget/confirm_order_badge.dart';

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
            ? () async {
                //set note
                ref.read(orderCreationProvider.notifier).setNote(noteController.text.trim());
                final isHaveInitialOrder = ref.read(orderCreationProvider.notifier).haveInitOrder;
                await ref.read(orderCreationProvider.notifier).saveDraft();
                if (isHaveInitialOrder) {
                  ref.invalidate(orderListProvider(OrderStatus.draft));
                }
              }
            : null,
        onSave: orderStaste.isNotEmpty
            ? () async {
                ref.read(orderCreationProvider.notifier).setNote(noteController.text.trim());
                final isHaveInitialOrder = ref.read(orderCreationProvider.notifier).haveInitOrder;
                await ref.read(orderCreationProvider.notifier).createOrder();
                if (isHaveInitialOrder) {
                  ref.invalidate(orderListProvider(OrderStatus.draft));
                  ref.invalidate(orderListProvider(OrderStatus.confirmed));
                }
              }
            : null,
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tạo đơn',
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.assignment_turned_in),
                color: Colors.white,
                tooltip: 'Danh sách đơn hàng',
                onPressed: () {
                  appRouter.goToOrderStatusList();
                },
              ),
              const Positioned(
                right: 4,
                child: ConfirmOrderBadge(),
              ),
            ],
          ),
        ],
      ),
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
                          ), //icon next
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
  SearchAndConfirmItemWidget<Product>(
    onConfirm: () {
      Navigator.pop(context);
    },
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

  bool get haveStock => product.quantity > 0;

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
                onChanged: !haveStock
                    ? null
                    : (value) {
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
                                  quantity: 1,
                                  // Mặc định số lượng là 1
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
                  maxValue: product.quantity,
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
            padding: const EdgeInsets.only(top: 16),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStaste = ref.watch(orderDetailProvider(order));
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);

    return permissionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber, size: 40, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  'Không thể tải quyền truy cập',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentUserPermissionsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (permissions) {
        final theme = context.appTheme;
        final canCreateOrEditOrder = permissions.contains(PermissionKey.orderCreate);
        final canCompleteOrder = permissions.contains(PermissionKey.orderComplete);
        final canCancelOrder = permissions.contains(PermissionKey.orderCancel);

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
          bottomNavigationBar: buildBottomButtonBar(
            context,
            order,
            orderStaste.order,
            ref,
            canCreateOrEdit: canCreateOrEditOrder,
            canComplete: canCompleteOrder,
            canCancel: canCancelOrder,
          ),
        );
      },
    );
  }

  Widget buildBottomButtonBar(
    BuildContext context,
    Order sourceOrder,
    Order? order,
    WidgetRef ref, {
    required bool canCreateOrEdit,
    required bool canComplete,
    required bool canCancel,
  }) {
    if (order == null) {
      return const SizedBox.shrink();
    }

    final actionHandler = ref.read(orderActionHandlerProvider);

    switch (order.status) {
      case OrderStatus.draft:
        if (!canCreateOrEdit) {
          return const SizedBox.shrink();
        }
        return BottomButtonBar(
          saveButtonText: 'Tạo đơn',
          cancelButtonText: 'Chỉnh sửa',
          showSaveButton: true,
          showCancelButton: true,
          onSave: () async {
            final confirmed = await actionHandler.confirmAction(
              context,
              OrderActionType.confirm,
              sourceOrder,
            );
            if (!confirmed) {
              return;
            }
            await ref.read(orderDetailProvider(sourceOrder).notifier).createOrder();
            ref.invalidate(orderListProvider(OrderStatus.draft));
            ref.invalidate(orderListProvider(OrderStatus.confirmed));
          },
          onCancel: () async {
            await appRouter.goToUpdateDraftOrder(sourceOrder);
          },
        );
      case OrderStatus.confirmed:
        final allowComplete = canComplete;
        final allowCancelOrder = canCancel;
        if (!allowComplete && !allowCancelOrder) {
          return const SizedBox.shrink();
        }
        return BottomButtonBar(
          saveButtonText: 'Hoàn thành',
          cancelButtonText: 'Huỷ đơn',
          showSaveButton: allowComplete,
          showCancelButton: allowCancelOrder,
          onSave: allowComplete
              ? () async {
                  final confirmed = await actionHandler.confirmAction(
                    context,
                    OrderActionType.confirm,
                    sourceOrder,
                  );
                  if (!confirmed) {
                    return;
                  }
                  await ref.read(orderDetailProvider(sourceOrder).notifier).completeOrder();
                  ref.invalidate(orderListProvider(OrderStatus.confirmed));
                  ref.invalidate(orderListProvider(OrderStatus.done));
                }
              : null,
          onCancel: allowCancelOrder
              ? () async {
                  final confirmed = await actionHandler.confirmAction(
                    context,
                    OrderActionType.cancel,
                    sourceOrder,
                  );
                  if (!confirmed) {
                    return;
                  }
                  await ref.read(orderDetailProvider(sourceOrder).notifier).cancelOrder();
                  ref.invalidate(orderListProvider(OrderStatus.confirmed));
                  ref.invalidate(orderListProvider(OrderStatus.cancelled));
                }
              : null,
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

class OrderNumberInputWidget extends HookConsumerWidget with ShowBottomSheet<void> {
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
    final quantity = useState(currentQuantity ?? 1);
    final productPrice = ref.watch(productPriceByIdProvider(product.id));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning message if quantity exceeds stock
          if (quantity.value > product.quantity)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Số lượng vượt quá tồn kho (${product.quantity})',
                      style: context.appTheme.textRegular12Default.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          CustomProductCard(product: product),
          const SizedBox(height: 16),

          // Inventory quantity display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_outlined,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tồn kho: ',
                  style: context.appTheme.textRegular14Default,
                ),
                Text(
                  '${product.quantity}',
                  style: context.appTheme.textMedium16Default.copyWith(color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product price display
          productPrice.when(
            data: (price) => price.sellingPrice != null
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giá bán: ',
                          style: context.appTheme.textRegular14Default,
                        ),
                        Text(
                          '${price.sellingPrice!.priceFormat()}',
                          style: context.appTheme.textMedium16Default.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),

          if (productPrice.valueOrNull?.sellingPrice != null) const SizedBox(height: 16),

          // Quantity input
          TitleBlockWidget.widget(
            titleWidget: Text(
              'Số lượng đặt hàng: ${quantity.value}',
              style: context.appTheme.textRegular13Subtle,
            ),
            child: PlusMinusInputView(
              initialValue: quantity.value, minValue: 1, maxValue: product.quantity, // Limit to available stock
              onChanged: (val) => quantity.value = val,
            ),
          ),

          // Bottom button bar
          BottomButtonBar(
            padding: const EdgeInsets.only(top: 16),
            onSave: quantity.value <= product.quantity
                ? () {
                    final price = productPrice.valueOrNull?.sellingPrice ?? 0;
                    onSave(quantity.value, price);
                    showSuccess(message: 'Đã thêm ${product.name} vào đơn hàng');
                  }
                : null, // Disable if quantity exceeds stock
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/order/order.dart';
import '../../core/helpers/double_utils.dart';
import '../../core/index.dart';
import '../../provider/index.dart';
import '../../resources/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import 'provider/order_list_provider.dart';

@RoutePage()
class OrderStatusListPage extends ConsumerStatefulWidget {
  const OrderStatusListPage({super.key});

  @override
  ConsumerState<OrderStatusListPage> createState() => _OrderStatusListPageState();
}

class _OrderStatusListPageState extends ConsumerState<OrderStatusListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderStatus> statuses = [
    OrderStatus.draft,
    OrderStatus.confirmed,
    OrderStatus.done,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: statuses.length,
      vsync: this,
      initialIndex: 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Danh sách dơn hàng',
        bottom: TabBar(
          labelStyle: theme.textMedium15Default.copyWith(color: Colors.white),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          controller: _tabController,
          tabs: statuses.map((status) {
            return Consumer(
              builder: (context, ref, child) {
                final orders = ref.watch(orderListProvider(status));
                final count = orders.data.length;
                return Tab(
                  text: '${status.displayName} ($count)',
                );
              },
            );
          }).toList(),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrderListView(
            status: OrderStatus.draft,
            itemBuilder: (BuildContext context, Order oder, int index) {
              return OrderCard(
                order: oder,
                onRemove: () {
                  ref.read(orderListProvider(OrderStatus.draft).notifier).removeOrder(oder);
                },
              );
            },
          ),
          OrderListView(
            status: OrderStatus.confirmed,
            itemBuilder: (BuildContext context, Order oder, int index) {
              return OrderCard(
                order: oder,
                onComplete: () async {
                  await ref.read(orderListProvider(OrderStatus.confirmed).notifier).confirmOrder(oder);
                  ref.invalidate(orderListProvider(OrderStatus.done));
                },
                onCancel: () async {
                  //cancel order
                  await ref.read(orderListProvider(OrderStatus.confirmed).notifier).cancelOrder(oder);
                  ref.invalidate(orderListProvider(OrderStatus.cancelled));
                },
              );
            },
          ),
          OrderListView(
            status: OrderStatus.done,
            itemBuilder: (BuildContext context, Order oder, int index) {
              return OrderCard(
                order: oder,
                onRemove: () {
                  ref.read(orderListProvider(OrderStatus.done).notifier).removeOrder(oder);
                },
              );
            },
          ),
          OrderListView(
            status: OrderStatus.cancelled,
            itemBuilder: (BuildContext context, Order oder, int index) {
              return OrderCard(
                order: oder,
                onRemove: () {
                  ref.read(orderListProvider(OrderStatus.cancelled).notifier).removeOrder(oder);
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appRouter.goToCreateOrder().whenComplete(
            () {
              ref.invalidate(orderListProvider(OrderStatus.draft));
              ref.invalidate(orderListProvider(OrderStatus.confirmed));
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class OrderListView extends ConsumerWidget {
  const OrderListView({
    super.key,
    required this.status,
    required this.itemBuilder,
  });

  final OrderStatus status;
  final Widget Function(BuildContext context, Order oder, int index) itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider(status));

    if (orders.data.isEmpty && !orders.isLoading) {
      return OrderEmptyState(status: status);
    }

    return LoadMoreList<Order>(
      items: orders.data,
      itemBuilder: (context, index) {
        final order = orders.data[index];
        return itemBuilder(context, order, index);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      onLoadMore: () async {
        return Future(
          () {
            return ref.read(orderListProvider(status).notifier).loadMore();
          },
        );
      },
      isCanLoadMore: !orders.isEndOfList,
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onRemove,
    this.onComplete,
    this.onCancel,
  });

  final Order order;
  final VoidCallback? onRemove;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return InkWell(
      onTap: () {
        appRouter.goToOrderDetail(order);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Mã đơn hàng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã đơn hàng: #${order.id}',
                        style: theme.textMedium15Default,
                      ),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(order.orderDate)}',
                        style: theme.textRegular14Sublest,
                      ),
                    ],
                  ),
                  Gap(8),
                  Row(
                    children: [
                      //Tên khách hàng
                      Text(
                        'Khách hàng: ${order.customer.isNotNullOrEmpty ? order.customer : 'Chưa có'}',
                        style: theme.textRegular15Default,
                      ),
                      VerticalDivider(),
                      //contact
                      Text(
                        'Liên hệ: ${order.customerContact.isNotNullOrEmpty ? order.customerContact : 'Chưa có'}',
                        style: theme.textRegular14Sublest,
                      ),
                    ],
                  ),

                  Gap(8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        Row(
                          children: [
                            //Sản phẩm
                            //Số sản phẩm
                            Text(
                              'Sản phẩm:',
                              style: theme.textRegular13Subtle,
                            ),
                            Gap(4),
                            Text(
                              '${order.productCount}',
                              style: theme.textRegular15Default,
                            ),
                            //Tổng tiền
                          ],
                        ),
                        Gap(20),
                        Row(
                          children: [
                            //Sản phẩm
                            //Số sản phẩm
                            Text(
                              'Số lượng:',
                              style: theme.textRegular13Subtle,
                            ),
                            Gap(4),
                            Text(
                              '${order.totalAmount}',
                              style: theme.textRegular15Default,
                            ),
                            //Tổng tiền
                          ],
                        ),
                        Gap(20),
                        Row(
                          children: [
                            //Sản phẩm
                            //Số sản phẩm
                            Text(
                              'Tổng tiền: ',
                              style: theme.textRegular13Subtle,
                            ),
                            Gap(4),
                            Text(
                              '${order.totalPrice.priceFormat()}',
                              style: theme.textRegular15Default,
                            ),
                            //Tổng tiền
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (order.note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Ghi chú: ${order.note!}',
                        style: theme.textRegular15Subtle,
                      ),
                    ),
                ],
              ),
              const Gap(10),
              const AppDivider(),
              const Gap(4),
              buildTrailing(
                context,
                order.status,
                theme,
              ),
            ],
          )),
    );
  }

  Widget buildTrailing(BuildContext context, OrderStatus status, AppThemeData theme) {
    switch (status) {
      case OrderStatus.confirmed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //Button: Hoàn thành
            TextButton(
              onPressed: onComplete,
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
                backgroundColor: Colors.green.withOpacity(0.1),
              ),
              child: Text(
                'Hoàn thành',
                style: theme.textRegular15Default.copyWith(color: Colors.green),
              ),
            ),
            Gap(12),
            //Button: Huỷ
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
              child: Text(
                'Hủy',
                style: theme.textRegular15Default.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
      case OrderStatus.draft:
      case OrderStatus.done:
      case OrderStatus.cancelled:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
              child: Text(
                'Xoá',
                style: theme.textRegular15Default.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
    }
  }
}

class OrderEmptyState extends StatelessWidget {
  const OrderEmptyState({
    super.key,
    required this.status,
  });

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    String getMessage() {
      switch (status) {
        case OrderStatus.draft:
          return 'Chưa có đơn hàng nháp nào';
        case OrderStatus.confirmed:
          return 'Chưa có đơn hàng đã xác nhận';
        case OrderStatus.done:
          return 'Chưa có đơn hàng hoàn thành';
        case OrderStatus.cancelled:
          return 'Chưa có đơn hàng bị hủy';
      }
    }

    IconData getIcon() {
      switch (status) {
        case OrderStatus.draft:
          return Icons.edit_note_outlined;
        case OrderStatus.confirmed:
          return Icons.check_circle_outline;
        case OrderStatus.done:
          return Icons.task_alt_outlined;
        case OrderStatus.cancelled:
          return Icons.cancel_outlined;
      }
    }

    Color getIconColor() {
      switch (status) {
        case OrderStatus.draft:
          return Colors.orange;
        case OrderStatus.confirmed:
          return Colors.blue;
        case OrderStatus.done:
          return Colors.green;
        case OrderStatus.cancelled:
          return Colors.red;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getIcon(),
            size: 80,
            color: getIconColor().withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            getMessage(),
            style: theme.textRegular16Subtle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để tạo đơn hàng mới',
            style: theme.textRegular14Sublest,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

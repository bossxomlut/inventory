import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/order/order_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../../../resources/index.dart';

part 'order_list_provider.g.dart';

final orderSearchKeywordProvider =
    StateProvider.family<String, OrderStatus>((ref, status) => '');

final confirmedOrderSelectionProvider = AutoDisposeNotifierProvider<
    MultipleSelectController<Order>, MultipleSelectState<Order>>(
  () => MultipleSelectController<Order>(),
);

@riverpod
class OrderList extends _$OrderList
    with LoadListController<Order>, CommonProvider<LoadListState<Order>> {
  //create a method to listen filter changes to call reload data

  @override
  LoadListState<Order> build(OrderStatus status) {
    ref.listen<String>(
      orderSearchKeywordProvider(status),
      (previous, next) {
        final previousValue = previous?.trim();
        final nextValue = next.trim();
        if (previous == null && nextValue.isEmpty) {
          return;
        }
        if (previousValue == nextValue) {
          return;
        }
        search(nextValue);
      },
    );

    Future(refresh);

    return LoadListState<Order>.initial();
  }

  @override
  Future<LoadResult<Order>> fetchData(LoadListQuery query) {
    final orderRepository = ref.read(orderRepositoryProvider);
    return orderRepository.getOrdersByStatus(status, query);
  }

  Future<void> removeOrder(Order order) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.deleteOrder(order);

    final updatedOrders = List<Order>.from(state.data);
    updatedOrders.remove(order);
    state = state.copyWith(data: updatedOrders);
    showSuccess(
      LKey.orderDeleteSuccess.tr(
        namedArgs: {'orderId': '${order.id}'},
      ),
    );
  }

  Future<void> cancelOrder(Order oder) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.cancelOrder(oder);

    final updatedOrders = List<Order>.from(state.data);
    updatedOrders.remove(oder);
    state = state.copyWith(data: updatedOrders);

    showSuccess(
      LKey.orderCancelSuccess.tr(
        namedArgs: {'orderId': '${oder.id}'},
      ),
    );
  }

  Future<void> confirmOrder(Order oder) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.completeOrder(oder);

    final updatedOrders = List<Order>.from(state.data);
    updatedOrders.remove(oder);
    state = state.copyWith(data: updatedOrders);
    showSuccess(
      LKey.orderCompleteSuccess.tr(
        namedArgs: {'orderId': '${oder.id}'},
      ),
    );
  }

  Future<void> confirmOrdersBulk(Iterable<Order> orders) async {
    final items = orders.toList();
    if (items.isEmpty) {
      return;
    }
    showLoading();
    try {
      final orderRepository = ref.read(orderRepositoryProvider);
      for (final order in items) {
        await orderRepository.completeOrder(order);
      }

      final currentSearch = query.search;
      await loadData(
        query: LoadListQueryX.defaultQuery.copyWith(search: currentSearch),
      );

      showSuccess(
        LKey.orderListBulkSuccess.tr(
          namedArgs: {'count': '${items.length}'},
        ),
      );

      if (status == OrderStatus.confirmed) {
        ref.invalidate(orderListProvider(OrderStatus.done));
      }
    } catch (_) {
      showError(LKey.orderListBulkError.tr());
    } finally {
      hideLoading();
    }
  }

  Future<List<Order>> fetchAllOrders() {
    final orderRepository = ref.read(orderRepositoryProvider);
    return orderRepository.getAllOrdersByStatus(status);
  }
}

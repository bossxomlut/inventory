import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/index.dart';
import '../../../domain/repositories/order/order_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';

part 'order_list_provider.g.dart';

@riverpod
class OrderList extends _$OrderList with LoadListController<Order>, CommonProvider<LoadListState<Order>> {
  //create a method to listen filter changes to call reload data

  @override
  LoadListState<Order> build(OrderStatus status) {
    Future(() {
      refresh();
    });

    return LoadListState<Order>.initial();
  }

  @override
  Future<LoadResult<Order>> fetchData(LoadListQuery query) {
    final orderRepository = ref.read(orderRepositoryProvider);
    return orderRepository.getOrdersByStatus(status, query);
  }

  void removeOrder(Order order) {
    final orderRepository = ref.read(orderRepositoryProvider);
    orderRepository.deleteOrder(order);

    final updatedOrders = List<Order>.from(state.data);
    updatedOrders.remove(order);
    state = state.copyWith(data: updatedOrders);
    showSuccess('Xóa đơn hàng thành công đơn #${order.id}');
  }

  void cancelOrder(Order oder) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.cancelOrder(oder);

    final updatedOrders = List<Order>.from(state.data);
    updatedOrders.remove(oder);
    state = state.copyWith(data: updatedOrders);

    showSuccess('Hủy đơn hàng thành công đơn #${oder.id}');
  }

  void confirmOrder(Order oder) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    await orderRepository.completeOrder(oder);

    final updatedOrders = List<Order>.from(state.data);
    updatedOrders.remove(oder);
    state = state.copyWith(data: updatedOrders);
    showSuccess('Chúc mừng bạn đã hoàn thành đơn hàng #${oder.id}');
  }
}

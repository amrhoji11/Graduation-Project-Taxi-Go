import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/create_order_model.dart';
import 'package:taxi_go_new/models/order_model.dart';
import 'package:taxi_go_new/models/update_order_model.dart';
import 'package:taxi_go_new/repositories/order_repository.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository orderRepository;

  OrderCubit({
    required this.orderRepository,
  }) : super(const OrderInitial());

  Future<void> getOrders({DateTime? fromDate, DateTime? toDate}) async {
    emit(const OrderLoading());

    try {
      final orders = await orderRepository.getOrders(
        fromDate: fromDate,
        toDate: toDate,
      );

      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderFailure(message: e.toString()));
    }
  }

  Future<void> createOrder(CreateOrderModel model) async {
    emit(const OrderLoading());

    try {
      final order = await orderRepository.createOrder(model);
      emit(OrderDetailLoaded(order: order));
    } catch (e) {
      emit(OrderFailure(message: e.toString()));
    }
  }

  Future<void> getOrderDetail(int orderId) async {
    emit(const OrderLoading());

    try {
      final order = await orderRepository.getOrderById(orderId);
      emit(OrderDetailLoaded(order: order));
    } catch (e) {
      emit(OrderFailure(message: e.toString()));
    }
  }

  /// Background re-fetch for realtime updates and pull-to-refresh - skips
  /// the `OrderLoading` state so the screen doesn't flash a full-screen
  /// spinner over already-displayed data, and keeps the last good state on
  /// a transient failure instead of replacing it with an error screen.
  Future<void> refreshOrderDetail(int orderId) async {
    try {
      final order = await orderRepository.getOrderById(orderId);
      emit(OrderDetailLoaded(order: order));
    } catch (_) {
      // Silent: this is a background refresh, not a user-initiated action.
    }
  }

  Future<void> updateOrder({
    required int orderId,
    required UpdateOrderModel model,
  }) async {
    emit(const OrderLoading());

    try {
      final message = await orderRepository.updateOrder(
        orderId: orderId,
        model: model,
      );
      emit(OrderActionSuccess(message: message));
    } catch (e) {
      emit(OrderFailure(message: e.toString()));
    }
  }

  Future<void> cancelOrder(int orderId) async {
    emit(const OrderLoading());

    try {
      final message = await orderRepository.cancelOrder(orderId);
      emit(OrderActionSuccess(message: message));
    } catch (e) {
      emit(OrderFailure(message: e.toString()));
    }
  }

  Future<void> rateDriver({
    required int orderId,
    required int stars,
    String? comment,
  }) async {
    emit(const OrderLoading());

    try {
      await orderRepository.rateDriver(
        orderId: orderId,
        stars: stars,
        comment: comment,
      );
      emit(const OrderActionSuccess(message: 'Rating submitted successfully'));
    } catch (e) {
      emit(OrderFailure(message: e.toString()));
    }
  }
}

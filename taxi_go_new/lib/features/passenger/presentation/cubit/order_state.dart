part of 'order_cubit.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  const OrdersLoaded({
    required this.orders,
  });
}

class OrderDetailLoaded extends OrderState {
  final OrderDetailModel order;

  const OrderDetailLoaded({
    required this.order,
  });
}

/// Emitted after a successful cancel/edit/rate action - the backend returns
/// a plain status message string for these, not an updated order object.
class OrderActionSuccess extends OrderState {
  final String message;

  const OrderActionSuccess({
    required this.message,
  });
}

class OrderFailure extends OrderState {
  final String message;

  const OrderFailure({
    required this.message,
  });
}

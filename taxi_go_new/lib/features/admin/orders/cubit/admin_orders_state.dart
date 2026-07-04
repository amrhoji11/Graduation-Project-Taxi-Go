part of 'admin_orders_cubit.dart';

abstract class AdminOrdersState {
  const AdminOrdersState();
}

class AdminOrdersInitial extends AdminOrdersState {
  const AdminOrdersInitial();
}

class AdminOrdersLoading extends AdminOrdersState {
  const AdminOrdersLoading();
}

class AdminOrdersLoaded extends AdminOrdersState {
  final PagedResultModel<AdminOrderModel> result;

  const AdminOrdersLoaded({required this.result});
}

class AdminOrdersFailure extends AdminOrdersState {
  final String message;

  const AdminOrdersFailure({required this.message});
}

class AdminOrdersActionSuccess extends AdminOrdersState {
  final String message;

  const AdminOrdersActionSuccess({required this.message});
}

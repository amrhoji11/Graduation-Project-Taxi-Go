part of 'admin_passengers_cubit.dart';

abstract class AdminPassengersState {
  const AdminPassengersState();
}

class AdminPassengersInitial extends AdminPassengersState {
  const AdminPassengersInitial();
}

class AdminPassengersLoading extends AdminPassengersState {
  const AdminPassengersLoading();
}

class AdminPassengersLoaded extends AdminPassengersState {
  final List<PassengerModel> passengers;

  const AdminPassengersLoaded({required this.passengers});
}

class AdminPassengersActionSuccess extends AdminPassengersState {
  final String message;

  const AdminPassengersActionSuccess({required this.message});
}

class AdminPassengersFailure extends AdminPassengersState {
  final String message;

  const AdminPassengersFailure({required this.message});
}

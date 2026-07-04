part of 'admin_trips_cubit.dart';

abstract class AdminTripsState {
  const AdminTripsState();
}

class AdminTripsInitial extends AdminTripsState {
  const AdminTripsInitial();
}

class AdminTripsLoading extends AdminTripsState {
  const AdminTripsLoading();
}

class AdminTripsLoaded extends AdminTripsState {
  final PagedResultModel<AdminTripModel> result;

  const AdminTripsLoaded({required this.result});
}

class AdminTripsFailure extends AdminTripsState {
  final String message;

  const AdminTripsFailure({required this.message});
}

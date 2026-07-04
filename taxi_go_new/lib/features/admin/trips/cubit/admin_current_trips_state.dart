part of 'admin_current_trips_cubit.dart';

abstract class AdminCurrentTripsState {
  const AdminCurrentTripsState();
}

class AdminCurrentTripsInitial extends AdminCurrentTripsState {
  const AdminCurrentTripsInitial();
}

class AdminCurrentTripsLoading extends AdminCurrentTripsState {
  const AdminCurrentTripsLoading();
}

class AdminCurrentTripsLoaded extends AdminCurrentTripsState {
  final List<AdminCurrentTripModel> trips;

  const AdminCurrentTripsLoaded({required this.trips});
}

class AdminCurrentTripsFailure extends AdminCurrentTripsState {
  final String message;

  const AdminCurrentTripsFailure({required this.message});
}

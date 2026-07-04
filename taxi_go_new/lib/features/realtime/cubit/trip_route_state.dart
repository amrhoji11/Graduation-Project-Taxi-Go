part of 'trip_route_cubit.dart';

abstract class TripRouteState {
  const TripRouteState();
}

class TripRouteInitial extends TripRouteState {
  const TripRouteInitial();
}

class TripRouteLoaded extends TripRouteState {
  final TripRouteModel route;
  final LatLng? driverPosition;

  const TripRouteLoaded({required this.route, this.driverPosition});
}

class TripRouteFailure extends TripRouteState {
  final String message;

  const TripRouteFailure({required this.message});
}

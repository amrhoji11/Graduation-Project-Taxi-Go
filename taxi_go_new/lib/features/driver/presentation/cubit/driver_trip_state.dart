part of 'driver_trip_cubit.dart';

abstract class DriverTripState {
  const DriverTripState();
}

class DriverTripInitial extends DriverTripState {
  const DriverTripInitial();
}

class DriverTripLoading extends DriverTripState {
  const DriverTripLoading();
}

class DriverTripActionSuccess extends DriverTripState {
  final String message;

  const DriverTripActionSuccess({
    required this.message,
  });
}

class DriverTripFailure extends DriverTripState {
  final String message;

  const DriverTripFailure({
    required this.message,
  });
}
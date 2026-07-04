part of 'driver_location_cubit.dart';

abstract class DriverLocationState {
  const DriverLocationState();
}

class DriverLocationInitial extends DriverLocationState {
  const DriverLocationInitial();
}

class DriverLocationSending extends DriverLocationState {
  const DriverLocationSending();
}

class DriverLocationSent extends DriverLocationState {
  final double latitude;
  final double longitude;

  const DriverLocationSent({required this.latitude, required this.longitude});
}

class DriverLocationFailure extends DriverLocationState {
  final String message;

  const DriverLocationFailure({
    required this.message,
  });
}
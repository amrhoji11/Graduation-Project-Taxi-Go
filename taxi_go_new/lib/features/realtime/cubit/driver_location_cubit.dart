import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:taxi_go_new/core/services/location_service.dart';
import 'package:taxi_go_new/core/services/signalr_service.dart';

part 'driver_location_state.dart';

class DriverLocationCubit extends Cubit<DriverLocationState> {
  final SignalRService signalRService;
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;

  DriverLocationCubit({required this.signalRService})
    : super(const DriverLocationInitial());

  /// Sends a single location update. Backend: `NotificationHub.SendLocation`
  /// derives the driver id from the JWT, so it is not passed here.
  Future<void> sendDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    emit(const DriverLocationSending());

    try {
      await signalRService.sendLocation(latitude, longitude);
      emit(DriverLocationSent(latitude: latitude, longitude: longitude));
    } catch (e) {
      emit(DriverLocationFailure(message: e.toString()));
    }
  }

  /// Starts streaming the device's GPS position to the backend until
  /// [stopTracking] is called or the cubit is closed.
  Future<void> startTracking() async {
    await _positionSubscription?.cancel();

    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        sendDriverLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      },
      onError: (e) {
        emit(DriverLocationFailure(message: e.toString()));
      },
    );
  }

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}

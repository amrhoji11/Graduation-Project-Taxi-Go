import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/services/signalr_service.dart';

part 'realtime_trip_state.dart';

class RealtimeTripCubit extends Cubit<RealtimeTripState> {
  final SignalRService signalRService;

  /// Every event `NotificationHub` actually sends to clients (see
  /// `NotificationHub`, `DriverTrackingRepository`, `TripRoutingService`,
  /// `NotificationRepository`, `DriverAssignmentRepository`,
  /// `MessageRepository` on the backend). There is no `/tripHub` and no
  /// `TripUpdated` / `OrderAccepted` / `DriverArrived` / `TripCompleted`
  /// events on the backend.
  static const List<String> _backendEvents = [
    'ReceiveNotification',
    'DriverLocationUpdated',
    'RouteUpdated',
    'UpdateTripStatus',
    'UpdateDriverStatus',
    'LeaveTrip',
    'ReceiveMessage',
  ];

  RealtimeTripCubit({required this.signalRService})
    : super(const RealtimeTripInitial());

  Future<void> connectToTripHub() async {
    emit(const RealtimeTripConnecting());

    try {
      await signalRService.connect();
      _listenToEvents();
      emit(const RealtimeTripConnected());
    } catch (e) {
      emit(RealtimeTripFailure(message: e.toString()));
    }
  }

  /// Subscribes to the `trip-{tripId}` group so this client receives that
  /// trip's `DriverLocationUpdated` / `RouteUpdated` / `UpdateTripStatus` /
  /// `ReceiveMessage` events.
  Future<void> joinTrip(int tripId) {
    return signalRService.joinTrip(tripId);
  }

  Future<void> leaveTrip(int tripId) {
    return signalRService.leaveTrip(tripId);
  }

  void _listenToEvents() {
    for (final eventName in _backendEvents) {
      // `connectToTripHub()` can be called again while the underlying
      // SignalR connection is still alive (e.g. opening a second order
      // detail screen) - without `off()` first, the hub stacks another
      // handler per call, so a single server event fires N times and was
      // the root cause of the order-detail screen's reload "flicker".
      signalRService.off(eventName);
      signalRService.on(eventName, (arguments) {
        emit(RealtimeTripUpdated(eventName: eventName, data: arguments));
      });
    }
  }

  Future<void> disconnect() async {
    for (final eventName in _backendEvents) {
      signalRService.off(eventName);
    }
    await signalRService.disconnect();
    emit(const RealtimeTripDisconnected());
  }
}

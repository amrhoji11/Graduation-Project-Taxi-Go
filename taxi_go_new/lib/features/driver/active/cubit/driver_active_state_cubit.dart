import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/services/signalr_service.dart';
import 'package:taxi_go_new/models/driver_active_state_model.dart';
import 'package:taxi_go_new/repositories/driver_trip_repository.dart';

part 'driver_active_state_state.dart';

/// Watches `GET /DriverTrips/active` (the durable state backstop) and the
/// `ReceiveNotification` SignalR event (type `NewTripOffer`) to detect when
/// the backend has pushed a new order offer or moved the driver onto an
/// active trip - the backend has no "browse pending orders" endpoint, offers
/// are pushed to a specific driver, not listed.
class DriverActiveStateCubit extends Cubit<DriverActiveStateState> {
  final DriverTripRepository driverTripRepository;
  final SignalRService signalRService;

  void Function(List<Object?>?)? _notificationHandler;

  // Guards against overlapping fetches - a `NewTripOffer` notification
  // delivered twice in quick succession (dual-group delivery, a missed
  // reconnect, etc) would otherwise trigger two concurrent `refresh()`
  // calls. Since this cubit holds exactly one offer at a time (never a
  // list), a duplicate notification can't render a duplicate card either
  // way, but this avoids the redundant network round-trip and any
  // out-of-order emit.
  bool _isRefreshing = false;

  DriverActiveStateCubit({
    required this.driverTripRepository,
    required this.signalRService,
  }) : super(const DriverActiveStateInitial());

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final data = await driverTripRepository.getActiveState();
      emit(DriverActiveStateLoaded(data: data));
    } catch (e) {
      emit(DriverActiveStateFailure(message: e.toString()));
    } finally {
      _isRefreshing = false;
    }
  }

  /// Connects to the shared hub and starts listening for `NewTripOffer`
  /// notifications, then does an immediate [refresh] so any offer/trip that
  /// already existed before this screen opened is recovered right away.
  Future<void> startWatching() async {
    try {
      await signalRService.connect();

      _notificationHandler = (arguments) {
        final payload = (arguments != null && arguments.isNotEmpty)
            ? arguments[0]
            : null;

        if (payload is Map && payload['type'] == 'NewTripOffer') {
          refresh();
        }
      };

      signalRService.on('ReceiveNotification', _notificationHandler!);
    } catch (_) {
      // Live push unavailable - refresh() below still works as the durable
      // backstop the backend documents DriverActiveStateDto to be.
    }

    await refresh();
  }

  void stopWatching() {
    signalRService.off('ReceiveNotification');
    _notificationHandler = null;
  }
}

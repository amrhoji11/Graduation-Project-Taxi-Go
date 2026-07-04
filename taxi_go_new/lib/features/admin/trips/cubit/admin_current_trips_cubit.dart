import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/services/signalr_service.dart';
import 'package:taxi_go_new/models/admin_current_trip_model.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';

part 'admin_current_trips_state.dart';

/// Drives the admin live-trips map/list. Realtime is layered on top of a
/// 10s poll, never instead of it:
/// - `DriverLocationUpdated` (already broadcast to the "office" SignalR
///   group for every location ping - see `DriverTrackingRepository`) is
///   applied as an in-place marker update with zero network round-trip, so
///   driver dots move smoothly between polls.
/// - `AdminTripStatusChanged` (broadcast once per arrive/start/pickup/
///   dropoff/cancel - see `DriverAssignmentRepository.NotifyOfficeTripChangedAsync`)
///   triggers an immediate re-fetch instead of waiting for the next tick.
/// - New trip creation isn't pushed (would require instrumenting the large,
///   many-exit-path matching algorithm - too risky for the value), so a
///   brand new active trip can take up to one poll interval to appear.
/// If the realtime connection is ever unavailable, the poll timer alone
/// still keeps this screen correct, just at a coarser cadence.
class AdminCurrentTripsCubit extends Cubit<AdminCurrentTripsState> {
  final AdminRepository adminRepository;
  final SignalRService signalRService;
  Timer? _pollTimer;
  bool _listenersAttached = false;

  AdminCurrentTripsCubit({
    required this.adminRepository,
    required this.signalRService,
  }) : super(const AdminCurrentTripsInitial());

  Future<void> load() async {
    emit(const AdminCurrentTripsLoading());
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final trips = await adminRepository.getCurrentTrips();
      emit(AdminCurrentTripsLoaded(trips: trips));
    } catch (e) {
      emit(AdminCurrentTripsFailure(message: e.toString()));
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => _fetch());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Best-effort - if the hub connection fails, polling already covers this
  /// screen completely, so failures here are swallowed rather than surfaced.
  Future<void> startRealtime() async {
    try {
      await signalRService.connect();

      if (!_listenersAttached) {
        signalRService.off('DriverLocationUpdated');
        signalRService.off('AdminTripStatusChanged');

        signalRService.on('DriverLocationUpdated', _onDriverLocationUpdated);
        signalRService.on('AdminTripStatusChanged', (_) => _fetch());

        _listenersAttached = true;
      }
    } catch (_) {
      // Polling remains the source of truth.
    }
  }

  /// Only detaches this screen's own listeners - the hub connection is a
  /// single shared instance used by other features (notifications, etc.),
  /// so it must not be torn down just because this screen closed.
  void stopRealtime() {
    if (!_listenersAttached) return;
    signalRService.off('DriverLocationUpdated');
    signalRService.off('AdminTripStatusChanged');
    _listenersAttached = false;
  }

  void _onDriverLocationUpdated(List<Object?>? arguments) {
    final state = this.state;
    if (state is! AdminCurrentTripsLoaded) return;
    if (arguments == null || arguments.isEmpty) return;

    final payload = arguments.first;
    if (payload is! Map) return;

    final driverId = payload['driverId']?.toString();
    final lat = _toDouble(payload['lat']);
    final lng = _toDouble(payload['lng']);
    if (driverId == null || lat == null || lng == null) return;

    var changed = false;
    final updated = state.trips.map((trip) {
      if (trip.driverId != driverId) return trip;
      changed = true;
      return trip.copyWithDriverLocation(lat: lat, lng: lng);
    }).toList();

    if (changed) {
      emit(AdminCurrentTripsLoaded(trips: updated));
    }
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    stopRealtime();
    return super.close();
  }
}
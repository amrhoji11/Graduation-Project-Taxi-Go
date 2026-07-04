import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi_go_new/models/trip_route_model.dart';

part 'trip_route_state.dart';

/// Holds a trip's real road route plus the driver's latest known
/// position, and recomputes completed/remaining progress as either one
/// changes. Shared by the Driver Trip Details and Passenger Order Detail
/// screens - the only thing that differs between them is *how* a route is
/// fetched (different REST endpoint per role), passed in as [loadRoute].
///
/// This cubit is deliberately SignalR-agnostic: the owning screen already
/// listens to `RealtimeTripCubit` for `RouteUpdated`/`DriverLocationUpdated`
/// and calls [applyRouteUpdate]/[updateDriverPosition] with the parsed
/// payload, the same way it already routes other event names to specific
/// actions (e.g. a silent refresh on `UpdateTripStatus`).
class TripRouteCubit extends Cubit<TripRouteState> {
  final Future<TripRouteModel> Function() loadRoute;

  TripRouteCubit({required this.loadRoute}) : super(const TripRouteInitial());

  Future<void> load() async {
    try {
      final route = await loadRoute();
      emit(_merge(route: route));
    } catch (e) {
      emit(TripRouteFailure(message: e.toString()));
    }
  }

  /// Replaces the held route with a freshly pushed/fetched one, keeping
  /// whatever driver position is already known.
  void applyRouteUpdate(TripRouteModel route) {
    emit(_merge(route: route));
  }

  /// Updates only the driver's position - the cheap, frequent update path
  /// (every GPS ping), recomputing progress without touching the route
  /// itself.
  void updateDriverPosition(double lat, double lng) {
    emit(_merge(driverPosition: LatLng(lat, lng)));
  }

  TripRouteLoaded _merge({TripRouteModel? route, LatLng? driverPosition}) {
    final current = state;
    final previousRoute = current is TripRouteLoaded ? current.route : TripRouteModel.empty;
    final previousPosition = current is TripRouteLoaded ? current.driverPosition : null;

    return TripRouteLoaded(
      route: route ?? previousRoute,
      driverPosition: driverPosition ?? previousPosition,
    );
  }
}

import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/cancel_trip_model.dart';
import 'package:taxi_go_new/models/driver_active_state_model.dart';
import 'package:taxi_go_new/models/trip_route_model.dart';

class DriverTripRepository {
  final ApiClient apiClient;

  DriverTripRepository({required this.apiClient});

  /// `GET /DriverTrips/active` - the durable backstop for recovering what
  /// the driver app should show right now (Idle / pending offer / active
  /// trip), independent of SignalR events that may have been missed.
  Future<DriverActiveStateModel> getActiveState() async {
    final response = await apiClient.get(ApiEndpoints.driverActiveState);
    return DriverActiveStateModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> acceptOrder(int orderId) async {
    await apiClient.post(ApiEndpoints.acceptOrder(orderId));
  }

  Future<void> rejectOrder(int orderId) async {
    await apiClient.post(ApiEndpoints.rejectOrder(orderId));
  }

  Future<void> arrived(int orderId) async {
    await apiClient.post(ApiEndpoints.arrived(orderId));
  }

  Future<void> startTrip(int tripId) async {
    await apiClient.post(ApiEndpoints.startTrip(tripId));
  }

  Future<void> pickupPassenger(int orderId) async {
    await apiClient.post(ApiEndpoints.pickupPassenger(orderId));
  }

  Future<void> dropOffPassenger(int orderId) async {
    await apiClient.post(ApiEndpoints.dropOffPassenger(orderId));
  }

  Future<void> cancelTrip({
    required int tripId,
    required TripCancelReason reason,
  }) async {
    final model = CancelTripModel(reason: reason);

    await apiClient.post(ApiEndpoints.cancelTrip(tripId), data: model.toJson());
  }

  /// `GET /DriverTrips/route/{tripId}` - real road route + baseline ETA
  /// for this driver's own active trip, the pull counterpart to the
  /// `RouteUpdated` SignalR push (for when this screen opens after the
  /// last push already fired).
  Future<TripRouteModel> getRoute(int tripId) async {
    final response = await apiClient.get(ApiEndpoints.driverTripRoute(tripId));
    return TripRouteModel.fromJson(response.data as Map<String, dynamic>);
  }
}

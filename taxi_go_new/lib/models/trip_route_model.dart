import 'package:taxi_go_new/models/route_point_model.dart';

/// A trip's real road route plus its baseline (pre-departure) ETA. Shared
/// by the Driver and Passenger sides - both the new `GET .../route/{id}`
/// pull endpoints and the `RouteUpdated` SignalR push use the same field
/// names (`routePoints`/`totalMinutes`), so one parser covers both the
/// driver's full payload and the passenger-safe subset.
class TripRouteModel {
  final List<RoutePointModel> points;
  final int totalMinutes;

  const TripRouteModel({this.points = const [], this.totalMinutes = 0});

  static const empty = TripRouteModel();

  bool get hasRoute => points.length >= 2;

  factory TripRouteModel.fromJson(Map<String, dynamic> json) {
    final pointsJson = json['routePoints'] as List<dynamic>? ?? [];

    return TripRouteModel(
      points: pointsJson
          .map((e) => RoutePointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalMinutes: _toInt(json['totalMinutes']),
    );
  }

  /// Parses the raw `RouteUpdated` SignalR payload as handed back by
  /// `RealtimeTripCubit` (`RealtimeTripUpdated.data`, a
  /// `List<Object?>?` of hub method arguments - the event carries exactly
  /// one argument, the payload object).
  factory TripRouteModel.fromRouteUpdatedArgs(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return empty;

    final payload = arguments.first;
    if (payload is! Map) return empty;

    return TripRouteModel.fromJson(Map<String, dynamic>.from(payload));
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

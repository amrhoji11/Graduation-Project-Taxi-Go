import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/route_point_model.dart';

/// Matches `AdminCurrentTripOrderDto` (nested inside `AdminCurrentTripDto`).
class AdminCurrentTripOrderModel {
  final int orderId;
  final String passengerName;
  final String pickupLocation;
  final double pickupLat;
  final double pickupLng;
  final String? dropoffLocation;
  final double? dropoffLat;
  final double? dropoffLng;

  const AdminCurrentTripOrderModel({
    required this.orderId,
    required this.passengerName,
    required this.pickupLocation,
    required this.pickupLat,
    required this.pickupLng,
    this.dropoffLocation,
    this.dropoffLat,
    this.dropoffLng,
  });

  factory AdminCurrentTripOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminCurrentTripOrderModel(
      orderId: json['orderId'] ?? 0,
      passengerName: json['passengerName'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      pickupLat: _toDouble(json['pickupLat']),
      pickupLng: _toDouble(json['pickupLng']),
      dropoffLocation: json['dropoffLocation'],
      dropoffLat: _toDoubleNullable(json['dropoffLat']),
      dropoffLng: _toDoubleNullable(json['dropoffLng']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    return _toDouble(value);
  }
}

/// Matches `AdminCurrentTripDto` returned by `GET /api/Admin/CurrentTrips` -
/// one entry per active trip, used by the admin live-trips map/list screen.
class AdminCurrentTripModel {
  final int tripId;
  final TripStatusType status;
  final String detailedStatus;

  final String? driverId;
  final String driverName;
  final String? driverPhone;
  final String? driverProfilePhotoUrl;
  final double? driverLastLat;
  final double? driverLastLng;
  final DateTime? driverLastSeenAt;

  final String? vehiclePlateNumber;
  final String? vehicleMake;
  final String? vehicleModel;

  final List<AdminCurrentTripOrderModel> orders;

  /// Driver -> [pickup ->] dropoff waypoints, real road geometry ready to
  /// draw as a polyline. Empty (never a straight line) if the backend's
  /// routing-service call failed.
  final List<RoutePointModel> routePoints;
  final int? etaMinutes;
  final double? totalDistanceMeters;
  final double? coveredDistanceMeters;
  final double? remainingDistanceMeters;

  const AdminCurrentTripModel({
    required this.tripId,
    required this.status,
    required this.detailedStatus,
    this.driverId,
    required this.driverName,
    this.driverPhone,
    this.driverProfilePhotoUrl,
    this.driverLastLat,
    this.driverLastLng,
    this.driverLastSeenAt,
    this.vehiclePlateNumber,
    this.vehicleMake,
    this.vehicleModel,
    this.orders = const [],
    this.routePoints = const [],
    this.etaMinutes,
    this.totalDistanceMeters,
    this.coveredDistanceMeters,
    this.remainingDistanceMeters,
  });

  /// Used to apply a realtime `DriverLocationUpdated` push in place,
  /// without re-fetching the whole trip list from the server. Route/ETA/
  /// distance fields are left as last computed by the server until the
  /// next poll - recomputing them client-side would need the same Maps
  /// API call the backend just made, so they intentionally lag by up to
  /// one poll interval rather than triggering an extra round-trip per
  /// location ping.
  AdminCurrentTripModel copyWithDriverLocation({
    required double lat,
    required double lng,
  }) {
    return AdminCurrentTripModel(
      tripId: tripId,
      status: status,
      detailedStatus: detailedStatus,
      driverId: driverId,
      driverName: driverName,
      driverPhone: driverPhone,
      driverProfilePhotoUrl: driverProfilePhotoUrl,
      driverLastLat: lat,
      driverLastLng: lng,
      driverLastSeenAt: DateTime.now(),
      vehiclePlateNumber: vehiclePlateNumber,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      orders: orders,
      routePoints: routePoints,
      etaMinutes: etaMinutes,
      totalDistanceMeters: totalDistanceMeters,
      coveredDistanceMeters: coveredDistanceMeters,
      remainingDistanceMeters: remainingDistanceMeters,
    );
  }

  factory AdminCurrentTripModel.fromJson(Map<String, dynamic> json) {
    final ordersJson = json['orders'] as List<dynamic>? ?? [];
    final routePointsJson = json['routePoints'] as List<dynamic>? ?? [];

    return AdminCurrentTripModel(
      tripId: json['tripId'] ?? 0,
      status: TripStatusType.fromValue(json['status']),
      detailedStatus: json['detailedStatus'] ?? '',
      driverId: json['driverId'],
      driverName: json['driverName'] ?? 'Unknown',
      driverPhone: json['driverPhone'],
      driverProfilePhotoUrl: json['driverProfilePhotoUrl'],
      driverLastLat: _toDoubleNullable(json['driverLastLat']),
      driverLastLng: _toDoubleNullable(json['driverLastLng']),
      driverLastSeenAt: json['driverLastSeenAt'] != null
          ? DateTime.tryParse(json['driverLastSeenAt'].toString())
          : null,
      vehiclePlateNumber: json['vehiclePlateNumber'],
      vehicleMake: json['vehicleMake'],
      vehicleModel: json['vehicleModel'],
      orders: ordersJson
          .map((e) => AdminCurrentTripOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      routePoints: routePointsJson
          .map((e) => RoutePointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      etaMinutes: json['etaMinutes'] is int ? json['etaMinutes'] as int : null,
      totalDistanceMeters: _toDoubleNullable(json['totalDistanceMeters']),
      coveredDistanceMeters: _toDoubleNullable(json['coveredDistanceMeters']),
      remainingDistanceMeters: _toDoubleNullable(json['remainingDistanceMeters']),
    );
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

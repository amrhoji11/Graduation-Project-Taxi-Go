import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/admin_order_model.dart';
import 'package:taxi_go_new/models/vehicle_model.dart';

/// Matches `OrderDto` returned by `GET /api/Orders/GetAll` (passenger's own
/// order list). The backend has no fare/price field anywhere on `Order` -
/// there is no fare calculation in this system, so no `price` field exists
/// here.
class OrderModel {
  final int orderId;
  final String passengerName;
  final double pickupLat;
  final double pickupLng;
  final String pickupLocation;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffLocation;
  final int passengerCount;
  final OrderPriorityType priority;
  final VehicleSize? requiredVehicleSize;
  final OrderStatusType status;
  final int tripId;
  final OrderRatingModel? rating;
  final DateTime? createdAt;
  final DateTime? scheduledAt;

  const OrderModel({
    required this.orderId,
    required this.passengerName,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupLocation,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffLocation,
    required this.passengerCount,
    required this.priority,
    this.requiredVehicleSize,
    required this.status,
    required this.tripId,
    this.rating,
    this.createdAt,
    this.scheduledAt,
  });

  /// Has the passenger already been assigned a driver/trip for this order.
  bool get hasTrip => tripId > 0;

  /// Orders in these statuses are still ongoing (not finished/cancelled).
  bool get isActive =>
      status == OrderStatusType.pending ||
      status == OrderStatusType.searchingDriver ||
      status == OrderStatusType.pendingOfficeReview ||
      status == OrderStatusType.assignedToTrip;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: _toInt(json['orderId']),
      passengerName: json['passengerName'] ?? '',
      pickupLat: _toDouble(json['pickupLat']),
      pickupLng: _toDouble(json['pickupLng']),
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLat: _toDoubleNullable(json['dropoffLat']),
      dropoffLng: _toDoubleNullable(json['dropoffLng']),
      dropoffLocation: json['dropoffLocation'],
      passengerCount: _toInt(json['passengerCount']),
      priority: OrderPriorityType.fromValue(json['priority']),
      requiredVehicleSize: json['requiredVehicleSize'] != null
          ? VehicleSize.fromValue(json['requiredVehicleSize'])
          : null,
      status: OrderStatusType.fromValue(json['status']),
      tripId: _toInt(json['tripId']),
      rating: json['rating'] != null
          ? OrderRatingModel.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
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

/// Matches `OrderDetailDto` returned by `POST /Orders/CreateOrder` and
/// `GET /Orders/{id}` - includes trip/driver/vehicle info once a driver has
/// been assigned (all null/unset before that, per the backend DTO comment).
class OrderDetailModel {
  final int orderId;
  final double pickupLat;
  final double pickupLng;
  final String pickupLocation;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffLocation;
  final int passengerCount;
  final OrderPriorityType priority;
  final VehicleSize? requiredVehicleSize;
  final OrderStatusType status;
  final DateTime? createdAt;
  final DateTime? scheduledAt;
  final OrderRatingModel? rating;

  final int? tripId;
  final TripStatusType? tripStatus;
  final String? driverId;
  final String? driverName;
  final String? driverProfilePhotoUrl;
  final double? driverLastLat;
  final double? driverLastLng;
  final String? vehiclePlateNumber;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleColor;
  final int? vehicleSeats;

  const OrderDetailModel({
    required this.orderId,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupLocation,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffLocation,
    required this.passengerCount,
    required this.priority,
    this.requiredVehicleSize,
    required this.status,
    this.createdAt,
    this.scheduledAt,
    this.rating,
    this.tripId,
    this.tripStatus,
    this.driverId,
    this.driverName,
    this.driverProfilePhotoUrl,
    this.driverLastLat,
    this.driverLastLng,
    this.vehiclePlateNumber,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleSeats,
  });

  bool get hasDriverAssigned => driverId != null;

  /// Orders in these statuses can still be cancelled/edited by the
  /// passenger - mirrors what makes sense given `OrdersController` has no
  /// separate "is cancellable" flag, only the raw status.
  bool get isActive =>
      status == OrderStatusType.pending ||
      status == OrderStatusType.searchingDriver ||
      status == OrderStatusType.pendingOfficeReview ||
      status == OrderStatusType.assignedToTrip;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      orderId: _toInt(json['orderId']),
      pickupLat: _toDouble(json['pickupLat']),
      pickupLng: _toDouble(json['pickupLng']),
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLat: _toDoubleNullable(json['dropoffLat']),
      dropoffLng: _toDoubleNullable(json['dropoffLng']),
      dropoffLocation: json['dropoffLocation'],
      passengerCount: _toInt(json['passengerCount']),
      priority: OrderPriorityType.fromValue(json['priority']),
      requiredVehicleSize: json['requiredVehicleSize'] != null
          ? VehicleSize.fromValue(json['requiredVehicleSize'])
          : null,
      status: OrderStatusType.fromValue(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      rating: json['rating'] != null
          ? OrderRatingModel.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
      tripId: _toIntNullable(json['tripId']),
      tripStatus: json['tripStatus'] != null
          ? TripStatusType.fromValue(json['tripStatus'])
          : null,
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverProfilePhotoUrl: json['driverProfilePhotoUrl'],
      driverLastLat: _toDoubleNullable(json['driverLastLat']),
      driverLastLng: _toDoubleNullable(json['driverLastLng']),
      vehiclePlateNumber: json['vehiclePlateNumber'],
      vehicleMake: json['vehicleMake'],
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      vehicleSeats: _toIntNullable(json['vehicleSeats']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
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

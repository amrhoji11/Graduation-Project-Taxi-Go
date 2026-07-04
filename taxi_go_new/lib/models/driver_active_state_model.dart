import 'package:taxi_go_new/models/vehicle_model.dart';

/// Mirrors backend `DriverActiveStateType` (DriverActiveStateDto.cs) - raw
/// int, no JsonStringEnumConverter on the backend.
enum DriverActiveStateType {
  idle,
  offerPending,
  onTrip;

  static DriverActiveStateType fromValue(dynamic value) {
    if (value is int &&
        value >= 0 &&
        value < DriverActiveStateType.values.length) {
      return DriverActiveStateType.values[value];
    }
    return DriverActiveStateType.idle;
  }
}

/// Mirrors backend `TripStatus` (Trip.cs).
enum DriverTripStatus {
  pending,
  assigned,
  driverArrived,
  inProgress,
  completed,
  cancelled,
  searchingDriver,
  noDriverFound;

  static DriverTripStatus fromValue(dynamic value) {
    if (value is int && value >= 0 && value < DriverTripStatus.values.length) {
      return DriverTripStatus.values[value];
    }
    return DriverTripStatus.pending;
  }

  String get label {
    switch (this) {
      case DriverTripStatus.pending:
        return 'Pending';
      case DriverTripStatus.assigned:
        return 'Assigned';
      case DriverTripStatus.driverArrived:
        return 'Driver arrived';
      case DriverTripStatus.inProgress:
        return 'In progress';
      case DriverTripStatus.completed:
        return 'Completed';
      case DriverTripStatus.cancelled:
        return 'Cancelled';
      case DriverTripStatus.searchingDriver:
        return 'Searching driver';
      case DriverTripStatus.noDriverFound:
        return 'No driver found';
    }
  }
}

/// Mirrors backend `TripOrderStatus` (TripOrder.cs) - the status of the
/// single stop/order within a trip.
enum TripOrderStatusType {
  assigned,
  pickedUp,
  droppedOff,
  cancelled,
  unassigned,
  driverArrived;

  static TripOrderStatusType fromValue(dynamic value) {
    if (value is int &&
        value >= 0 &&
        value < TripOrderStatusType.values.length) {
      return TripOrderStatusType.values[value];
    }
    return TripOrderStatusType.assigned;
  }

  String get label {
    switch (this) {
      case TripOrderStatusType.assigned:
        return 'Assigned';
      case TripOrderStatusType.pickedUp:
        return 'Picked up';
      case TripOrderStatusType.droppedOff:
        return 'Dropped off';
      case TripOrderStatusType.cancelled:
        return 'Cancelled';
      case TripOrderStatusType.unassigned:
        return 'Unassigned';
      case TripOrderStatusType.driverArrived:
        return 'Driver arrived';
    }
  }
}

/// Mirrors backend `OrderPriority` (Order.cs).
enum OrderPriorityType {
  normal,
  urgent;

  static OrderPriorityType fromValue(dynamic value) {
    if (value is int && value >= 0 && value < OrderPriorityType.values.length) {
      return OrderPriorityType.values[value];
    }
    return OrderPriorityType.normal;
  }
}

double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

double _toDouble(dynamic value) => _toDoubleNullable(value) ?? 0.0;

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// Mirrors `DriverActiveStateDto` (`GET /DriverTrips/active`) - the durable
/// backstop for recovering what the driver app should be showing right now
/// (an offer waiting for accept/reject, or an active trip), independent of
/// whatever was missed over SignalR while the app was closed/disconnected.
class DriverActiveStateModel {
  final DriverActiveStateType state;
  final DriverOrderOfferModel? offer;
  final DriverActiveTripModel? trip;

  const DriverActiveStateModel({required this.state, this.offer, this.trip});

  factory DriverActiveStateModel.fromJson(Map<String, dynamic> json) {
    return DriverActiveStateModel(
      state: DriverActiveStateType.fromValue(json['state']),
      offer: json['offer'] != null
          ? DriverOrderOfferModel.fromJson(
              json['offer'] as Map<String, dynamic>,
            )
          : null,
      trip: json['trip'] != null
          ? DriverActiveTripModel.fromJson(json['trip'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Mirrors `DriverOrderOfferDto`.
class DriverOrderOfferModel {
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
  final DateTime? offerExpiresAt;

  const DriverOrderOfferModel({
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
    this.offerExpiresAt,
  });

  factory DriverOrderOfferModel.fromJson(Map<String, dynamic> json) {
    return DriverOrderOfferModel(
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
      offerExpiresAt: json['offerExpiresAt'] != null
          ? DateTime.tryParse(json['offerExpiresAt'].toString())
          : null,
    );
  }
}

/// Mirrors `DriverActiveTripDto`.
class DriverActiveTripModel {
  final int tripId;
  final DriverTripStatus status;
  final DateTime? assignedAt;
  final DateTime? startTime;
  final List<DriverTripStopModel> stops;

  const DriverActiveTripModel({
    required this.tripId,
    required this.status,
    this.assignedAt,
    this.startTime,
    this.stops = const [],
  });

  factory DriverActiveTripModel.fromJson(Map<String, dynamic> json) {
    final stopsJson = json['stops'] as List<dynamic>? ?? [];

    return DriverActiveTripModel(
      tripId: _toInt(json['tripId']),
      status: DriverTripStatus.fromValue(json['status']),
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : null,
      stops: stopsJson
          .map((e) => DriverTripStopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Mirrors `DriverTripStopDto` - the passenger's pickup/dropoff within a
/// trip.
class DriverTripStopModel {
  final int orderId;
  final TripOrderStatusType statusInTrip;
  final double pickupLat;
  final double pickupLng;
  final String pickupLocation;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffLocation;
  final int passengerCount;
  final String passengerName;
  final String? passengerPhone;
  final String? passengerProfilePhotoUrl;

  const DriverTripStopModel({
    required this.orderId,
    required this.statusInTrip,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupLocation,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffLocation,
    required this.passengerCount,
    required this.passengerName,
    this.passengerPhone,
    this.passengerProfilePhotoUrl,
  });

  factory DriverTripStopModel.fromJson(Map<String, dynamic> json) {
    return DriverTripStopModel(
      orderId: _toInt(json['orderId']),
      statusInTrip: TripOrderStatusType.fromValue(json['statusInTrip']),
      pickupLat: _toDouble(json['pickupLat']),
      pickupLng: _toDouble(json['pickupLng']),
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLat: _toDoubleNullable(json['dropoffLat']),
      dropoffLng: _toDoubleNullable(json['dropoffLng']),
      dropoffLocation: json['dropoffLocation'],
      passengerCount: _toInt(json['passengerCount']),
      passengerName: json['passengerName'] ?? '',
      passengerPhone: json['passengerPhone'],
      passengerProfilePhotoUrl: json['passengerProfilePhotoUrl'],
    );
  }
}

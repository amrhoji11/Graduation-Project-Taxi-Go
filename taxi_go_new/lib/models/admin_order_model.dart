import 'package:taxi_go_new/models/admin_enums.dart';

/// Matches the nested `OrderRatingDto` (`Stars`, `Comment`) inside `OrderDto`.
class OrderRatingModel {
  final int? stars;
  final String? comment;

  const OrderRatingModel({this.stars, this.comment});

  factory OrderRatingModel.fromJson(Map<String, dynamic> json) {
    return OrderRatingModel(
      stars: json['stars'],
      comment: json['comment'],
    );
  }
}

/// Matches `OrderDto` returned by `GET /api/Admin/orders`.
class AdminOrderModel {
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
  final OrderStatusType status;
  final int tripId;
  final OrderRatingModel? rating;
  final DateTime? createdAt;

  const AdminOrderModel({
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
    required this.status,
    required this.tripId,
    this.rating,
    this.createdAt,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderModel(
      orderId: json['orderId'] ?? 0,
      passengerName: json['passengerName'] ?? '',
      pickupLat: _toDouble(json['pickupLat']),
      pickupLng: _toDouble(json['pickupLng']),
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLat: _toDoubleNullable(json['dropoffLat']),
      dropoffLng: _toDoubleNullable(json['dropoffLng']),
      dropoffLocation: json['dropoffLocation'],
      passengerCount: json['passengerCount'] ?? 0,
      priority: OrderPriorityType.fromValue(json['priority']),
      status: OrderStatusType.fromValue(json['status']),
      tripId: json['tripId'] ?? 0,
      rating: json['rating'] != null
          ? OrderRatingModel.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
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

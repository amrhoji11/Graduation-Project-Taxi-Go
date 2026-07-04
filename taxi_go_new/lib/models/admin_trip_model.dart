import 'package:taxi_go_new/models/admin_enums.dart';

/// Matches `TripDto` returned by `GET /api/Admin/trips`.
class AdminTripModel {
  final int tripId;
  final TripStatusType status;
  final String driverName;
  final int totalPassengers;
  final int ratingCount;
  final double tripRating;
  final bool isActive;
  final DateTime? createdAt;

  const AdminTripModel({
    required this.tripId,
    required this.status,
    required this.driverName,
    required this.totalPassengers,
    required this.ratingCount,
    required this.tripRating,
    required this.isActive,
    this.createdAt,
  });

  factory AdminTripModel.fromJson(Map<String, dynamic> json) {
    return AdminTripModel(
      tripId: json['tripId'] ?? 0,
      status: TripStatusType.fromValue(json['status']),
      driverName: json['driverName'] ?? '',
      totalPassengers: json['totalPassengers'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      tripRating: (json['tripRating'] is int)
          ? (json['tripRating'] as int).toDouble()
          : (json['tripRating'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

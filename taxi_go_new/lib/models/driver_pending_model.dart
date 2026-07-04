import 'package:taxi_go_new/models/driver_model.dart';

/// Matches `DriverPendingResponseDto` (one entry of `GET /DriverApprovals/pending`).
class DriverPendingModel {
  final String userId;
  final String fullName;
  final String phoneNumber;

  const DriverPendingModel({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
  });

  factory DriverPendingModel.fromJson(Map<String, dynamic> json) {
    return DriverPendingModel(
      userId: (json['userId'] ?? '').toString(),
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

/// Matches the anonymous object returned by `GET /DriverApprovals/{driverId}`
/// (`DriverApprovalRepository.GetDriverDetailsAsync`).
class DriverApprovalDetailsModel {
  final String driverId;
  final String name;
  final String? email;
  final String? phone;
  final String? profilePhotoUrl;
  final DriverStatus status;
  final DateTime? createdAt;
  final bool isActive;
  final bool isBlocked;
  final String? vehicleModel;
  final String? vehiclePlateNumber;
  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final double rating;
  final int ratingCount;

  const DriverApprovalDetailsModel({
    required this.driverId,
    required this.name,
    this.email,
    this.phone,
    this.profilePhotoUrl,
    required this.status,
    this.createdAt,
    this.isActive = true,
    this.isBlocked = false,
    this.vehicleModel,
    this.vehiclePlateNumber,
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.rating,
    required this.ratingCount,
  });

  factory DriverApprovalDetailsModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>?;

    return DriverApprovalDetailsModel(
      driverId: (json['driverId'] ?? '').toString(),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      profilePhotoUrl: json['profilePhotoUrl'],
      status: DriverStatus.fromValue(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      vehicleModel: vehicle?['model'],
      vehiclePlateNumber: vehicle?['plateNumber'],
      totalTrips: json['totalTrips'] ?? 0,
      completedTrips: json['completedTrips'] ?? 0,
      cancelledTrips: json['cancelledTrips'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}

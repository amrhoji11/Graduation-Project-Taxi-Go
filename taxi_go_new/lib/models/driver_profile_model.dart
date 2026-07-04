import 'package:taxi_go_new/models/driver_model.dart';
import 'package:taxi_go_new/models/vehicle_model.dart';

/// Mirrors backend `ApprovalStatus` (TaxiApp.Backend.Core.Models.DriverApproval) -
/// raw int, no JsonStringEnumConverter on the backend.
enum ApprovalStatusType {
  pending,
  approved,
  rejected;

  static ApprovalStatusType fromValue(dynamic value) {
    if (value is int &&
        value >= 0 &&
        value < ApprovalStatusType.values.length) {
      return ApprovalStatusType.values[value];
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'approved':
          return ApprovalStatusType.approved;
        case 'rejected':
          return ApprovalStatusType.rejected;
      }
    }

    return ApprovalStatusType.pending;
  }

  String get label {
    switch (this) {
      case ApprovalStatusType.pending:
        return 'Pending';
      case ApprovalStatusType.approved:
        return 'Approved';
      case ApprovalStatusType.rejected:
        return 'Rejected';
    }
  }
}

/// Mirrors `DriverProfileDto` (`GET /Drivers/profile`).
class DriverProfileModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phoneNumber;
  final String? address;
  final String? profilePhotoUrl;
  final DriverStatus status;
  final bool isInQueue;
  final ApprovalStatusType approvalStatus;
  final String? vehiclePlateNumber;
  final VehicleSize? vehicleSize;
  final int? vehicleSeats;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleColor;

  const DriverProfileModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phoneNumber,
    this.address,
    this.profilePhotoUrl,
    required this.status,
    required this.isInQueue,
    required this.approvalStatus,
    this.vehiclePlateNumber,
    this.vehicleSize,
    this.vehicleSeats,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      userId: (json['userId'] ?? '').toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'],
      profilePhotoUrl: json['profilePhotoUrl'],
      status: DriverStatus.fromValue(json['status']),
      isInQueue: json['isInQueue'] ?? false,
      approvalStatus: ApprovalStatusType.fromValue(json['approvalStatus']),
      vehiclePlateNumber: json['vehiclePlateNumber'],
      vehicleSize: json['vehicleSize'] != null
          ? VehicleSize.fromValue(json['vehicleSize'])
          : null,
      vehicleSeats: json['vehicleSeats'],
      vehicleMake: json['vehicleMake'],
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
    );
  }
}

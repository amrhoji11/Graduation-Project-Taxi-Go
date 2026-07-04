import 'package:taxi_go_new/models/complaint_enums.dart';

/// Matches `ViolationDto` returned by `GET /api/Complaints/violations`
/// (admin-only).
class ViolationModel {
  final int id;
  final String driverId;
  final String driverName;
  final ViolationTypeEnum type;
  final ViolationStatusType status;
  final String reason;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  const ViolationModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.type,
    required this.status,
    required this.reason,
    this.resolvedAt,
    this.createdAt,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) {
    return ViolationModel(
      id: json['id'] ?? json['violationId'] ?? 0,
      driverId: (json['driverId'] ?? '').toString(),
      driverName: json['driverName'] ?? '',
      type: ViolationTypeEnum.fromValue(json['type']),
      status: ViolationStatusType.fromValue(json['status']),
      reason: json['reason'] ?? json['description'] ?? '',
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

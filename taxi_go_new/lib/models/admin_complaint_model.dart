import 'package:taxi_go_new/models/complaint_enums.dart';
import 'package:taxi_go_new/models/violation_model.dart';

/// Matches `ComplaintDto` returned by `GET /api/Complaints/all` (admin-only).
/// This is intentionally separate from the simpler `ComplaintModel` used by
/// the passenger/driver complaint-creation flow, whose backend payload shape
/// is different (`CreateComplaintDto`).
class AdminComplaintModel {
  final int id;
  final String senderId;
  final String senderName;
  final String? againstUserId;
  final String? againstUserName;
  final int? orderId;
  final int? tripId;
  final ComplaintReasonType reasonType;
  final ComplaintTargetTypeEnum targetType;
  final String description;
  final ComplaintStatusType status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final int? violationId;
  final ViolationModel? violation;

  const AdminComplaintModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.againstUserId,
    this.againstUserName,
    this.orderId,
    this.tripId,
    required this.reasonType,
    required this.targetType,
    required this.description,
    required this.status,
    this.createdAt,
    this.resolvedAt,
    this.violationId,
    this.violation,
  });

  factory AdminComplaintModel.fromJson(Map<String, dynamic> json) {
    return AdminComplaintModel(
      id: json['id'] ?? 0,
      senderId: (json['senderId'] ?? '').toString(),
      senderName: json['senderName'] ?? '',
      againstUserId: json['againstUserId']?.toString(),
      againstUserName: json['againstUserName'],
      orderId: json['orderId'],
      tripId: json['tripId'],
      reasonType: ComplaintReasonType.fromValue(json['reasonType']),
      targetType: ComplaintTargetTypeEnum.fromValue(json['targetType']),
      description: json['description'] ?? '',
      status: ComplaintStatusType.fromValue(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
      violationId: json['violationId'],
      violation: json['violation'] != null
          ? ViolationModel.fromJson(json['violation'] as Map<String, dynamic>)
          : null,
    );
  }
}

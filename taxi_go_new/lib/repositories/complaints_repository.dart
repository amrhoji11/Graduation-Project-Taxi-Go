import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/admin_complaint_model.dart';
import 'package:taxi_go_new/models/complaint_enums.dart';
import 'package:taxi_go_new/models/complaint_model.dart';
import 'package:taxi_go_new/models/violation_model.dart';

class ComplaintsRepository {
  final ApiClient apiClient;

  ComplaintsRepository({
    required this.apiClient,
  });

  /// `POST /api/orders/{orderId}/complaints` - backend `CreateComplaintDto`
  /// requires `TargetType`/`ReasonType`/`Description`; there is no `title`
  /// field on the backend at all.
  Future<void> createComplaint({
    required int orderId,
    required ComplaintTargetTypeEnum targetType,
    required ComplaintReasonType reasonType,
    required String description,
  }) async {
    await apiClient.post(
      ApiEndpoints.createComplaint(orderId),
      data: {
        'targetType': targetType.index,
        'reasonType': reasonType.index,
        'description': description,
      },
    );
  }

  Future<List<ComplaintModel>> getComplaints() async {
    final response = await apiClient.get(ApiEndpoints.complaints);
    return _parseComplaints(response.data);
  }

  /// Backend `UpdateComplaintStatusDto` requires `Status`, `ViolationType`
  /// and `CreateViolation` (not just `status`) - `violationType` is still
  /// required by the DTO even when `createViolation` is false, so a
  /// placeholder value is sent in that case.
  Future<void> updateComplaintStatus({
    required int complaintId,
    required ComplaintStatusType status,
    required bool createViolation,
    ViolationTypeEnum violationType = ViolationTypeEnum.behavior,
    String? violationReason,
  }) async {
    await apiClient.patch(
      ApiEndpoints.updateComplaintStatus(complaintId),
      data: {
        'status': status.index,
        'violationType': violationType.index,
        'createViolation': createViolation,
        'violationReason': ?violationReason,
      },
    );
  }

  /// `GET /Complaints/all` (admin-only) - returns the full `ComplaintDto`
  /// shape, unlike `getComplaints()` above which is parsed into the
  /// simplified `ComplaintModel` used by the complaint-creation flow.
  Future<List<AdminComplaintModel>> getAdminComplaints() async {
    final response = await apiClient.get(ApiEndpoints.complaints);
    final data = response.data;

    if (data is List) {
      return data
          .map((e) => AdminComplaintModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => AdminComplaintModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<List<ViolationModel>> getViolations() async {
    final response = await apiClient.get(ApiEndpoints.violations);
    return _parseViolations(response.data);
  }

  Future<void> resolveViolation(int violationId) async {
    await apiClient.patch(
      ApiEndpoints.resolveViolation(violationId),
    );
  }

  List<ComplaintModel> _parseComplaints(dynamic data) {
    if (data is List) {
      return data
          .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  List<ViolationModel> _parseViolations(dynamic data) {
    if (data is List) {
      return data
          .map((e) => ViolationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => ViolationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => ViolationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
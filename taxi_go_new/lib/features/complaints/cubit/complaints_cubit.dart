import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/admin_complaint_model.dart';
import 'package:taxi_go_new/models/complaint_enums.dart';
import 'package:taxi_go_new/models/complaint_model.dart';
import 'package:taxi_go_new/models/violation_model.dart';
import 'package:taxi_go_new/repositories/complaints_repository.dart';

part 'complaints_state.dart';

class ComplaintsCubit extends Cubit<ComplaintsState> {
  final ComplaintsRepository complaintsRepository;

  ComplaintsCubit({
    required this.complaintsRepository,
  }) : super(const ComplaintsInitial());

  Future<void> getComplaints() async {
    emit(const ComplaintsLoading());

    try {
      final complaints = await complaintsRepository.getComplaints();

      emit(
        ComplaintsLoaded(
          complaints: complaints,
        ),
      );
    } catch (e) {
      emit(
        ComplaintsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> createComplaint({
    required int orderId,
    required ComplaintTargetTypeEnum targetType,
    required ComplaintReasonType reasonType,
    required String description,
  }) async {
    emit(const ComplaintsLoading());

    try {
      await complaintsRepository.createComplaint(
        orderId: orderId,
        targetType: targetType,
        reasonType: reasonType,
        description: description,
      );
      emit(
        const ComplaintsSuccess(
          message: 'Complaint submitted successfully',
        ),
      );
    } catch (e) {
      emit(
        ComplaintsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> updateComplaintStatus({
    required int complaintId,
    required ComplaintStatusType status,
    bool createViolation = false,
    ViolationTypeEnum violationType = ViolationTypeEnum.behavior,
    String? violationReason,
  }) async {
    emit(const ComplaintsLoading());

    try {
      await complaintsRepository.updateComplaintStatus(
        complaintId: complaintId,
        status: status,
        createViolation: createViolation,
        violationType: violationType,
        violationReason: violationReason,
      );

      emit(
        const ComplaintsSuccess(
          message: 'Complaint status updated',
        ),
      );

      await getAdminComplaints();
    } catch (e) {
      emit(
        ComplaintsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> getAdminComplaints() async {
    emit(const ComplaintsLoading());

    try {
      final complaints = await complaintsRepository.getAdminComplaints();

      emit(
        AdminComplaintsLoaded(
          complaints: complaints,
        ),
      );
    } catch (e) {
      emit(
        ComplaintsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> getViolations() async {
    emit(const ComplaintsLoading());

    try {
      final violations = await complaintsRepository.getViolations();

      emit(
        ViolationsLoaded(
          violations: violations,
        ),
      );
    } catch (e) {
      emit(
        ComplaintsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> resolveViolation(int violationId) async {
    emit(const ComplaintsLoading());

    try {
      await complaintsRepository.resolveViolation(violationId);

      emit(
        const ComplaintsSuccess(
          message: 'Violation resolved successfully',
        ),
      );

      await getViolations();
    } catch (e) {
      emit(
        ComplaintsFailure(
          message: e.toString(),
        ),
      );
    }
  }
}
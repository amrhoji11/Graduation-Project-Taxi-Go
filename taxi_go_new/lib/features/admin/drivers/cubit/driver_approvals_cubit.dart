import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/driver_pending_model.dart';
import 'package:taxi_go_new/repositories/driver_approvals_repository.dart';

part 'driver_approvals_state.dart';

class DriverApprovalsCubit extends Cubit<DriverApprovalsState> {
  final DriverApprovalsRepository driverApprovalsRepository;

  DriverApprovalsCubit({
    required this.driverApprovalsRepository,
  }) : super(const DriverApprovalsInitial());

  Future<void> getPendingDrivers() async {
    emit(const DriverApprovalsLoading());

    try {
      final drivers = await driverApprovalsRepository.getPendingDrivers();
      emit(PendingDriversLoaded(drivers: drivers));
    } catch (e) {
      emit(DriverApprovalsFailure(message: e.toString()));
    }
  }

  Future<void> approveDriver(String id) async {
    emit(const DriverApprovalsLoading());

    try {
      await driverApprovalsRepository.approveDriver(id);
      emit(const DriverApprovalsActionSuccess(message: 'Driver approved successfully'));
      await getPendingDrivers();
    } catch (e) {
      emit(DriverApprovalsFailure(message: e.toString()));
    }
  }

  Future<void> rejectDriver(String id, {String? notes}) async {
    emit(const DriverApprovalsLoading());

    try {
      await driverApprovalsRepository.rejectDriver(id, notes: notes);
      emit(const DriverApprovalsActionSuccess(message: 'Driver rejected successfully'));
      await getPendingDrivers();
    } catch (e) {
      emit(DriverApprovalsFailure(message: e.toString()));
    }
  }

  /// Transient lookup for the driver-details dialog - not part of
  /// [DriverApprovalsState] since it's only needed while that dialog is open.
  Future<DriverApprovalDetailsModel> fetchDriverDetails(String driverId) {
    return driverApprovalsRepository.getDriverDetails(driverId);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/driver_model.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';
import 'package:taxi_go_new/repositories/driver_repository.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final DriverRepository driverRepository;
  final AdminRepository adminRepository;

  AdminCubit({
    required this.driverRepository,
    required this.adminRepository,
  }) : super(const AdminInitial());

  Future<void> getDrivers() async {
    emit(const AdminLoading());

    try {
      final drivers = await driverRepository.getDrivers();

      emit(
        DriversLoaded(
          drivers: drivers,
        ),
      );
    } catch (e) {
      emit(
        AdminFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> softDeleteDriver(String id) async {
    emit(const AdminLoading());

    try {
      await driverRepository.softDeleteDriver(id);

      emit(
        const AdminActionSuccess(
          message: 'Driver deleted successfully',
        ),
      );

      await getDrivers();
    } catch (e) {
      emit(
        AdminFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreDriver(String id) async {
    emit(const AdminLoading());

    try {
      await driverRepository.restoreDriver(id);

      emit(
        const AdminActionSuccess(
          message: 'Driver restored successfully',
        ),
      );

      await getDrivers();
    } catch (e) {
      emit(
        AdminFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> toggleActive(String userId) async {
    try {
      await adminRepository.toggleUserActive(userId);
      emit(const AdminActionSuccess(message: 'Account status updated'));
      await getDrivers();
    } catch (e) {
      emit(AdminFailure(message: e.toString()));
    }
  }

  Future<void> toggleBlock(String userId, {String? reason, DateTime? endsAt}) async {
    try {
      final blocked = await adminRepository.toggleUserBlock(
        userId,
        reason: reason,
        endsAt: endsAt,
      );
      emit(
        AdminActionSuccess(
          message: blocked ? 'Driver blocked' : 'Driver unblocked',
        ),
      );
      await getDrivers();
    } catch (e) {
      emit(AdminFailure(message: e.toString()));
    }
  }
}
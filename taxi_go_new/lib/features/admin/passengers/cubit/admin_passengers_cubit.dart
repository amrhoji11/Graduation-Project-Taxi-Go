import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/passenger_model.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';

part 'admin_passengers_state.dart';

class AdminPassengersCubit extends Cubit<AdminPassengersState> {
  final AdminRepository adminRepository;

  AdminPassengersCubit({
    required this.adminRepository,
  }) : super(const AdminPassengersInitial());

  Future<void> getPassengers() async {
    emit(const AdminPassengersLoading());

    try {
      final passengers = await adminRepository.getPassengers();
      emit(AdminPassengersLoaded(passengers: passengers));
    } catch (e) {
      emit(AdminPassengersFailure(message: e.toString()));
    }
  }

  Future<void> softDeletePassenger(String id) async {
    emit(const AdminPassengersLoading());

    try {
      await adminRepository.softDeletePassenger(id);
      emit(const AdminPassengersActionSuccess(message: 'Passenger deleted successfully'));
      await getPassengers();
    } catch (e) {
      emit(AdminPassengersFailure(message: e.toString()));
    }
  }

  Future<void> restorePassenger(String id) async {
    emit(const AdminPassengersLoading());

    try {
      await adminRepository.restorePassenger(id);
      emit(const AdminPassengersActionSuccess(message: 'Passenger restored successfully'));
      await getPassengers();
    } catch (e) {
      emit(AdminPassengersFailure(message: e.toString()));
    }
  }

  /// Transient lookup for the passenger-details dialog - not part of
  /// [AdminPassengersState] since it's only needed while that dialog is open.
  Future<PassengerProfileModel> fetchPassengerProfile(String id) {
    return adminRepository.getPassengerProfile(id);
  }

  Future<void> toggleActive(String userId) async {
    try {
      await adminRepository.toggleUserActive(userId);
      emit(const AdminPassengersActionSuccess(message: 'Account status updated'));
      await getPassengers();
    } catch (e) {
      emit(AdminPassengersFailure(message: e.toString()));
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
        AdminPassengersActionSuccess(
          message: blocked ? 'Passenger blocked' : 'Passenger unblocked',
        ),
      );
      await getPassengers();
    } catch (e) {
      emit(AdminPassengersFailure(message: e.toString()));
    }
  }
}

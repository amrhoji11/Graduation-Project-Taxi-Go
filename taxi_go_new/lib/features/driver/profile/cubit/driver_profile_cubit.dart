import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/driver_profile_model.dart';
import 'package:taxi_go_new/repositories/driver_profile_repository.dart';

part 'driver_profile_state.dart';

class DriverProfileCubit extends Cubit<DriverProfileState> {
  final DriverProfileRepository driverProfileRepository;

  DriverProfileCubit({required this.driverProfileRepository})
    : super(const DriverProfileInitial());

  Future<void> loadProfile() async {
    emit(const DriverProfileLoading());

    try {
      final profile = await driverProfileRepository.getProfile();
      emit(DriverProfileLoaded(profile: profile));
    } catch (e) {
      emit(DriverProfileFailure(message: e.toString()));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? address,
    bool removeAddress = false,
    bool removeProfilePhoto = false,
    File? profilePhoto,
  }) async {
    emit(const DriverProfileLoading());

    try {
      await driverProfileRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        address: address,
        removeAddress: removeAddress,
        removeProfilePhoto: removeProfilePhoto,
        profilePhoto: profilePhoto,
      );
      final profile = await driverProfileRepository.getProfile();
      emit(DriverProfileUpdateSuccess(profile: profile));
    } catch (e) {
      emit(DriverProfileFailure(message: e.toString()));
    }
  }
}

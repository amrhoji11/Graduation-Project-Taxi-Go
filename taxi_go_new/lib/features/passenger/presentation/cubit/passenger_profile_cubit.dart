import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/passenger_model.dart';
import 'package:taxi_go_new/repositories/passenger_profile_repository.dart';

part 'passenger_profile_state.dart';

class PassengerProfileCubit extends Cubit<PassengerProfileState> {
  final PassengerProfileRepository passengerProfileRepository;

  PassengerProfileCubit({required this.passengerProfileRepository})
    : super(const PassengerProfileInitial());

  Future<void> loadProfile() async {
    emit(const PassengerProfileLoading());

    try {
      final profile = await passengerProfileRepository.getProfile();
      emit(PassengerProfileLoaded(profile: profile));
    } catch (e) {
      emit(PassengerProfileFailure(message: e.toString()));
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
    emit(const PassengerProfileLoading());

    try {
      await passengerProfileRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        address: address,
        removeAddress: removeAddress,
        removeProfilePhoto: removeProfilePhoto,
        profilePhoto: profilePhoto,
      );
      final profile = await passengerProfileRepository.getProfile();
      emit(PassengerProfileUpdateSuccess(profile: profile));
    } catch (e) {
      emit(PassengerProfileFailure(message: e.toString()));
    }
  }
}

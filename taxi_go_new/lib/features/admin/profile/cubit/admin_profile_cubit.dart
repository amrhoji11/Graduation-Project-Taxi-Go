import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/admin_profile_model.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';

part 'admin_profile_state.dart';

class AdminProfileCubit extends Cubit<AdminProfileState> {
  final AdminRepository adminRepository;

  AdminProfileCubit({
    required this.adminRepository,
  }) : super(const AdminProfileInitial());

  Future<void> getProfile() async {
    emit(const AdminProfileLoading());

    try {
      final profile = await adminRepository.getProfile();
      emit(AdminProfileLoaded(profile: profile));
    } catch (e) {
      emit(AdminProfileFailure(message: e.toString()));
    }
  }

  Future<void> editProfile({
    String? firstName,
    String? lastName,
    String? address,
    bool removeAddress = false,
    bool removeProfilePhoto = false,
    File? profilePhoto,
  }) async {
    emit(const AdminProfileLoading());

    try {
      await adminRepository.editProfile(
        firstName: firstName,
        lastName: lastName,
        address: address,
        removeAddress: removeAddress,
        removeProfilePhoto: removeProfilePhoto,
        profilePhoto: profilePhoto,
      );

      emit(const AdminProfileActionSuccess(message: 'Profile updated successfully'));
      await getProfile();
    } catch (e) {
      emit(AdminProfileFailure(message: e.toString()));
    }
  }
}

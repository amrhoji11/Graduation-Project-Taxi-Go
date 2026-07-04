part of 'admin_profile_cubit.dart';

abstract class AdminProfileState {
  const AdminProfileState();
}

class AdminProfileInitial extends AdminProfileState {
  const AdminProfileInitial();
}

class AdminProfileLoading extends AdminProfileState {
  const AdminProfileLoading();
}

class AdminProfileLoaded extends AdminProfileState {
  final AdminProfileModel profile;

  const AdminProfileLoaded({required this.profile});
}

class AdminProfileActionSuccess extends AdminProfileState {
  final String message;

  const AdminProfileActionSuccess({required this.message});
}

class AdminProfileFailure extends AdminProfileState {
  final String message;

  const AdminProfileFailure({required this.message});
}

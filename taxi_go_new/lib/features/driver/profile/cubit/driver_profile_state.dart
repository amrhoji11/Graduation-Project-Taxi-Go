part of 'driver_profile_cubit.dart';

abstract class DriverProfileState {
  const DriverProfileState();
}

class DriverProfileInitial extends DriverProfileState {
  const DriverProfileInitial();
}

class DriverProfileLoading extends DriverProfileState {
  const DriverProfileLoading();
}

class DriverProfileLoaded extends DriverProfileState {
  final DriverProfileModel profile;

  const DriverProfileLoaded({required this.profile});
}

/// Emitted instead of [DriverProfileLoaded] right after a successful
/// `updateProfile` call, so the screen can show a one-off confirmation.
class DriverProfileUpdateSuccess extends DriverProfileLoaded {
  const DriverProfileUpdateSuccess({required super.profile});
}

class DriverProfileFailure extends DriverProfileState {
  final String message;

  const DriverProfileFailure({required this.message});
}

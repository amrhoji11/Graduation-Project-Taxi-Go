part of 'passenger_profile_cubit.dart';

abstract class PassengerProfileState {
  const PassengerProfileState();
}

class PassengerProfileInitial extends PassengerProfileState {
  const PassengerProfileInitial();
}

class PassengerProfileLoading extends PassengerProfileState {
  const PassengerProfileLoading();
}

class PassengerProfileLoaded extends PassengerProfileState {
  final PassengerProfileModel profile;

  const PassengerProfileLoaded({required this.profile});
}

/// Emitted instead of [PassengerProfileLoaded] right after a successful
/// `updateProfile` call, so the screen can show a one-off confirmation.
class PassengerProfileUpdateSuccess extends PassengerProfileLoaded {
  const PassengerProfileUpdateSuccess({required super.profile});
}

class PassengerProfileFailure extends PassengerProfileState {
  final String message;

  const PassengerProfileFailure({required this.message});
}

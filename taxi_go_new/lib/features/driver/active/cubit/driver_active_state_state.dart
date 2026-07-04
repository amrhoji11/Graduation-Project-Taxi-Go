part of 'driver_active_state_cubit.dart';

abstract class DriverActiveStateState {
  const DriverActiveStateState();
}

class DriverActiveStateInitial extends DriverActiveStateState {
  const DriverActiveStateInitial();
}

class DriverActiveStateLoaded extends DriverActiveStateState {
  final DriverActiveStateModel data;

  const DriverActiveStateLoaded({required this.data});
}

class DriverActiveStateFailure extends DriverActiveStateState {
  final String message;

  const DriverActiveStateFailure({required this.message});
}

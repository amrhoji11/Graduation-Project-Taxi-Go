part of 'driver_approvals_cubit.dart';

abstract class DriverApprovalsState {
  const DriverApprovalsState();
}

class DriverApprovalsInitial extends DriverApprovalsState {
  const DriverApprovalsInitial();
}

class DriverApprovalsLoading extends DriverApprovalsState {
  const DriverApprovalsLoading();
}

class PendingDriversLoaded extends DriverApprovalsState {
  final List<DriverPendingModel> drivers;

  const PendingDriversLoaded({required this.drivers});
}

class DriverApprovalsActionSuccess extends DriverApprovalsState {
  final String message;

  const DriverApprovalsActionSuccess({required this.message});
}

class DriverApprovalsFailure extends DriverApprovalsState {
  final String message;

  const DriverApprovalsFailure({required this.message});
}

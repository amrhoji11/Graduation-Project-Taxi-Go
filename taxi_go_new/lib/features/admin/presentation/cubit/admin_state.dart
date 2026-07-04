part of 'admin_cubit.dart';

abstract class AdminState {
  const AdminState();
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class DriversLoaded extends AdminState {
  final List<DriverModel> drivers;

  const DriversLoaded({
    required this.drivers,
  });
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess({
    required this.message,
  });
}

class AdminFailure extends AdminState {
  final String message;

  const AdminFailure({
    required this.message,
  });
}
part of 'vehicle_cubit.dart';

abstract class VehicleState {
  const VehicleState();
}

class VehicleInitial extends VehicleState {
  const VehicleInitial();
}

class VehicleLoading extends VehicleState {
  const VehicleLoading();
}

class VehiclesLoaded extends VehicleState {
  final List<VehicleModel> vehicles;

  const VehiclesLoaded({
    required this.vehicles,
  });
}

class VehicleActionSuccess extends VehicleState {
  final String message;

  const VehicleActionSuccess({
    required this.message,
  });
}

class VehicleFailure extends VehicleState {
  final String message;

  const VehicleFailure({
    required this.message,
  });
}
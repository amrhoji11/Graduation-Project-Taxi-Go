import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/driver_model.dart';
import 'package:taxi_go_new/models/vehicle_model.dart';
import 'package:taxi_go_new/repositories/driver_repository.dart';
import 'package:taxi_go_new/repositories/vehicle_repository.dart';

part 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final VehicleRepository vehicleRepository;
  final DriverRepository driverRepository;

  VehicleCubit({
    required this.vehicleRepository,
    required this.driverRepository,
  }) : super(const VehicleInitial());

  /// Approved drivers only - for the vehicle registration/assignment
  /// driver picker (a vehicle must never be linked to a pending/rejected
  /// driver). Not part of [VehicleState] since it's only needed transiently
  /// while a dialog is open, not the main vehicles list UI.
  Future<List<DriverModel>> loadApprovedDrivers() {
    return driverRepository.getApprovedDrivers();
  }

  Future<void> getVehicles() async {
    emit(const VehicleLoading());

    try {
      final vehicles = await vehicleRepository.getVehicles();

      emit(
        VehiclesLoaded(
          vehicles: vehicles,
        ),
      );
    } catch (e) {
      emit(
        VehicleFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> addVehicle({
    required String driverId,
    required String plateNumber,
    required String make,
    required String model,
    required String color,
    required VehicleSize vehicleSize,
    required int seats,
    int? year,
    File? plateImage,
  }) async {
    emit(const VehicleLoading());

    try {
      await vehicleRepository.addVehicle(
        driverId: driverId,
        plateNumber: plateNumber,
        make: make,
        model: model,
        color: color,
        vehicleSize: vehicleSize,
        seats: seats,
        year: year,
        plateImage: plateImage,
      );

      emit(
        const VehicleActionSuccess(
          message: 'Vehicle added successfully',
        ),
      );

      await getVehicles();
    } catch (e) {
      emit(
        VehicleFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> updateVehicle({
    required int vehicleId,
    String? plateNumber,
    String? make,
    String? model,
    String? color,
    VehicleSize? vehicleSize,
    int? seats,
    int? year,
    File? plateImage,
  }) async {
    emit(const VehicleLoading());

    try {
      await vehicleRepository.updateVehicle(
        vehicleId: vehicleId,
        plateNumber: plateNumber,
        make: make,
        model: model,
        color: color,
        vehicleSize: vehicleSize,
        seats: seats,
        year: year,
        plateImage: plateImage,
      );

      emit(
        const VehicleActionSuccess(
          message: 'Vehicle updated successfully',
        ),
      );

      await getVehicles();
    } catch (e) {
      emit(
        VehicleFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> assignVehicle({
    required int vehicleId,
    required String driverId,
  }) async {
    emit(const VehicleLoading());

    try {
      await vehicleRepository.assignVehicle(
        vehicleId: vehicleId,
        driverId: driverId,
      );

      emit(
        const VehicleActionSuccess(
          message: 'Vehicle assigned successfully',
        ),
      );

      await getVehicles();
    } catch (e) {
      emit(
        VehicleFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> unassignVehicle(int vehicleId) async {
    emit(const VehicleLoading());

    try {
      await vehicleRepository.unassignVehicle(vehicleId);

      emit(
        const VehicleActionSuccess(
          message: 'Vehicle unassigned successfully',
        ),
      );

      await getVehicles();
    } catch (e) {
      emit(
        VehicleFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> changeVehicleStatus(int vehicleId) async {
    emit(const VehicleLoading());

    try {
      await vehicleRepository.changeVehicleStatus(vehicleId);

      emit(
        const VehicleActionSuccess(
          message: 'Vehicle status changed successfully',
        ),
      );

      await getVehicles();
    } catch (e) {
      emit(
        VehicleFailure(
          message: e.toString(),
        ),
      );
    }
  }
}

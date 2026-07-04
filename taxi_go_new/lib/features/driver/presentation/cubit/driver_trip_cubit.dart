import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_go_new/models/cancel_trip_model.dart';
import 'package:taxi_go_new/repositories/driver_trip_repository.dart';

part 'driver_trip_state.dart';

class DriverTripCubit extends Cubit<DriverTripState> {
  final DriverTripRepository driverTripRepository;

  DriverTripCubit({required this.driverTripRepository})
    : super(const DriverTripInitial());

  Future<void> acceptOrder(int orderId) async {
    emit(const DriverTripLoading());

    try {
      await driverTripRepository.acceptOrder(orderId);
      emit(
        const DriverTripActionSuccess(message: 'Order accepted successfully'),
      );
    } catch (e) {
      emit(DriverTripFailure(message: e.toString()));
    }
  }

  Future<void> rejectOrder(int orderId) async {
    emit(const DriverTripLoading());

    try {
      await driverTripRepository.rejectOrder(orderId);
      emit(
        const DriverTripActionSuccess(message: 'Order rejected successfully'),
      );
    } catch (e) {
      emit(DriverTripFailure(message: e.toString()));
    }
  }

  Future<void> arrived(int orderId) async {
    emit(const DriverTripLoading());

    try {
      await driverTripRepository.arrived(orderId);
      emit(
        const DriverTripActionSuccess(message: 'Driver arrived successfully'),
      );
    } catch (e) {
      emit(DriverTripFailure(message: e.toString()));
    }
  }

  Future<void> startTrip(int tripId) async {
    emit(const DriverTripLoading());

    try {
      await driverTripRepository.startTrip(tripId);
      emit(const DriverTripActionSuccess(message: 'Trip started successfully'));
    } catch (e) {
      emit(DriverTripFailure(message: e.toString()));
    }
  }

  Future<void> pickupPassenger(int orderId) async {
    emit(const DriverTripLoading());

    try {
      await driverTripRepository.pickupPassenger(orderId);
      emit(
        const DriverTripActionSuccess(
          message: 'Passenger picked up successfully',
        ),
      );
    } catch (e) {
      emit(DriverTripFailure(message: e.toString()));
    }
  }

  Future<void> dropOffPassenger(int orderId) async {
    emit(const DriverTripLoading());

    try {
      await driverTripRepository.dropOffPassenger(orderId);
      emit(
        const DriverTripActionSuccess(
          message: 'Passenger dropped off successfully',
        ),
      );
    } catch (e) {
      emit(DriverTripFailure(message: e.toString()));
    }
  }

  Future<void> cancelTrip({
    required int tripId,
    required TripCancelReason reason,
  }) async {
    emit(const DriverTripLoading());

    try {
      await driverTripRepository.cancelTrip(tripId: tripId, reason: reason);

      emit(
        const DriverTripActionSuccess(message: 'Trip cancelled successfully'),
      );
    } catch (e) {
      emit(DriverTripFailure(message: e.toString()));
    }
  }
}

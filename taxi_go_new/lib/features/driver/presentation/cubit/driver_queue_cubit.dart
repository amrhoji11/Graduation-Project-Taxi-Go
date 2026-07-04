import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/repositories/driver_queue_repository.dart';

part 'driver_queue_state.dart';

class DriverQueueCubit extends Cubit<DriverQueueState> {
  final DriverQueueRepository driverQueueRepository;

  DriverQueueCubit({required this.driverQueueRepository})
    : super(const DriverQueueInitial());

  Future<void> enterQueue() async {
    emit(const DriverQueueLoading());

    try {
      await driverQueueRepository.enterQueue();

      emit(
        const DriverQueueSuccess(message: 'You entered the queue successfully'),
      );
    } catch (e) {
      emit(DriverQueueFailure(message: e.toString()));
    }
  }

  Future<void> leaveQueue() async {
    emit(const DriverQueueLoading());

    try {
      await driverQueueRepository.leaveQueue();

      emit(
        const DriverQueueSuccess(message: 'You went offline'),
      );
    } catch (e) {
      emit(DriverQueueFailure(message: e.toString()));
    }
  }

  Future<void> returnToOffice() async {
    emit(const DriverQueueLoading());

    try {
      await driverQueueRepository.returnToOffice();

      emit(
        const DriverQueueSuccess(message: 'Marked as returning to office'),
      );
    } catch (e) {
      emit(DriverQueueFailure(message: e.toString()));
    }
  }
}

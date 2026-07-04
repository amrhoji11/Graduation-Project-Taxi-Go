part of 'driver_queue_cubit.dart';

abstract class DriverQueueState {
  const DriverQueueState();
}

class DriverQueueInitial extends DriverQueueState {
  const DriverQueueInitial();
}

class DriverQueueLoading extends DriverQueueState {
  const DriverQueueLoading();
}

class DriverQueueSuccess extends DriverQueueState {
  final String message;

  const DriverQueueSuccess({
    required this.message,
  });
}

class DriverQueueFailure extends DriverQueueState {
  final String message;

  const DriverQueueFailure({
    required this.message,
  });
}
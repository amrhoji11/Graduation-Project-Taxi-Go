part of 'realtime_trip_cubit.dart';

abstract class RealtimeTripState {
  const RealtimeTripState();
}

class RealtimeTripInitial extends RealtimeTripState {
  const RealtimeTripInitial();
}

class RealtimeTripConnecting extends RealtimeTripState {
  const RealtimeTripConnecting();
}

class RealtimeTripConnected extends RealtimeTripState {
  const RealtimeTripConnected();
}

class RealtimeTripUpdated extends RealtimeTripState {
  final String eventName;
  final dynamic data;

  const RealtimeTripUpdated({
    required this.eventName,
    required this.data,
  });
}

class RealtimeTripDisconnected extends RealtimeTripState {
  const RealtimeTripDisconnected();
}

class RealtimeTripFailure extends RealtimeTripState {
  final String message;

  const RealtimeTripFailure({
    required this.message,
  });
}
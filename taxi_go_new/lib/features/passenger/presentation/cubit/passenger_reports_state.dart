part of 'passenger_reports_cubit.dart';

abstract class PassengerReportsState {
  const PassengerReportsState();
}

class PassengerReportsInitial extends PassengerReportsState {
  const PassengerReportsInitial();
}

class PassengerReportsLoading extends PassengerReportsState {
  const PassengerReportsLoading();
}

class PassengerTripsReportLoaded extends PassengerReportsState {
  final List<PassengerTripReportModel> trips;

  const PassengerTripsReportLoaded({required this.trips});
}

class PassengerReportsFailure extends PassengerReportsState {
  final String message;

  const PassengerReportsFailure({required this.message});
}

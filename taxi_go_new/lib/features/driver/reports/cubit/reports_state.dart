part of 'reports_cubit.dart';

abstract class ReportsState {
  const ReportsState();
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class TripsReportLoaded extends ReportsState {
  final List<DriverTripReportModel> trips;

  const TripsReportLoaded({required this.trips});
}

class ReportsFailure extends ReportsState {
  final String message;

  const ReportsFailure({required this.message});
}

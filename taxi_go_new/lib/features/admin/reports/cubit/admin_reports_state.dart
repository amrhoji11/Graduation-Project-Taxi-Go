part of 'admin_reports_cubit.dart';

abstract class AdminReportsState {
  const AdminReportsState();
}

class AdminReportsInitial extends AdminReportsState {
  const AdminReportsInitial();
}

class AdminReportsLoading extends AdminReportsState {
  const AdminReportsLoading();
}

class TopDriversLoaded extends AdminReportsState {
  final List<TopDriverModel> drivers;

  const TopDriversLoaded({required this.drivers});
}

class AdminReportsFailure extends AdminReportsState {
  final String message;

  const AdminReportsFailure({required this.message});
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/driver_trip_report_model.dart';
import 'package:taxi_go_new/repositories/driver_profile_repository.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final DriverProfileRepository driverProfileRepository;

  ReportsCubit({required this.driverProfileRepository})
    : super(const ReportsInitial());

  Future<void> getTripsReport({DateTime? from, DateTime? to}) async {
    emit(const ReportsLoading());

    try {
      final trips = await driverProfileRepository.getMyTripsReport(
        from: from,
        to: to,
      );

      emit(TripsReportLoaded(trips: trips));
    } catch (e) {
      emit(ReportsFailure(message: e.toString()));
    }
  }
}

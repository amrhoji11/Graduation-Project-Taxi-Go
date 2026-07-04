import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/passenger_trip_report_model.dart';
import 'package:taxi_go_new/repositories/passenger_profile_repository.dart';

part 'passenger_reports_state.dart';

class PassengerReportsCubit extends Cubit<PassengerReportsState> {
  final PassengerProfileRepository passengerProfileRepository;

  PassengerReportsCubit({required this.passengerProfileRepository})
    : super(const PassengerReportsInitial());

  Future<void> getTripsReport({
    required DateTime from,
    required DateTime to,
  }) async {
    emit(const PassengerReportsLoading());

    try {
      final trips = await passengerProfileRepository.getTripsReport(
        from: from,
        to: to,
      );

      emit(PassengerTripsReportLoaded(trips: trips));
    } catch (e) {
      emit(PassengerReportsFailure(message: e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/admin_trip_model.dart';
import 'package:taxi_go_new/models/paged_result_model.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';

part 'admin_trips_state.dart';

class AdminTripsCubit extends Cubit<AdminTripsState> {
  final AdminRepository adminRepository;

  AdminTripsCubit({
    required this.adminRepository,
  }) : super(const AdminTripsInitial());

  Future<void> getTrips({int page = 1, int pageSize = 20}) async {
    emit(const AdminTripsLoading());

    try {
      final result = await adminRepository.getTrips(page: page, pageSize: pageSize);
      emit(AdminTripsLoaded(result: result));
    } catch (e) {
      emit(AdminTripsFailure(message: e.toString()));
    }
  }
}

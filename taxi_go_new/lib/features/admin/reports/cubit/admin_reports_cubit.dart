import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/top_driver_model.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';

part 'admin_reports_state.dart';

class AdminReportsCubit extends Cubit<AdminReportsState> {
  final AdminRepository adminRepository;

  AdminReportsCubit({
    required this.adminRepository,
  }) : super(const AdminReportsInitial());

  Future<void> getTopDrivers({int top = 5}) async {
    emit(const AdminReportsLoading());

    try {
      final drivers = await adminRepository.getTopDrivers(top: top);
      emit(TopDriversLoaded(drivers: drivers));
    } catch (e) {
      emit(AdminReportsFailure(message: e.toString()));
    }
  }
}

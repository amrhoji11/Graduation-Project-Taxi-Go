import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/admin_order_model.dart';
import 'package:taxi_go_new/models/driver_model.dart';
import 'package:taxi_go_new/models/paged_result_model.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';

part 'admin_orders_state.dart';

class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  final AdminRepository adminRepository;

  AdminOrdersCubit({
    required this.adminRepository,
  }) : super(const AdminOrdersInitial());

  Future<void> getOrders({int page = 1, int pageSize = 20}) async {
    emit(const AdminOrdersLoading());

    try {
      final result = await adminRepository.getOrders(page: page, pageSize: pageSize);
      emit(AdminOrdersLoaded(result: result));
    } catch (e) {
      emit(AdminOrdersFailure(message: e.toString()));
    }
  }

  /// Drivers eligible for manual assignment - used to populate the picker in
  /// the order-detail "Assign driver" dialog. Transient lookup, not part of
  /// [AdminOrdersState] since it's only needed while that dialog is open.
  Future<List<DriverModel>> loadAssignableDrivers() {
    return adminRepository.getAssignableDrivers();
  }

  Future<void> manualAssignOrder({
    required int orderId,
    required String driverId,
  }) async {
    try {
      final message = await adminRepository.manualAssignOrder(
        orderId: orderId,
        driverId: driverId,
      );
      emit(AdminOrdersActionSuccess(message: message));
      await getOrders();
    } catch (e) {
      emit(AdminOrdersFailure(message: e.toString()));
    }
  }
}

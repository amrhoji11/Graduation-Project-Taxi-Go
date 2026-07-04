import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/driver_model.dart';

class DriverRepository {
  final ApiClient apiClient;

  DriverRepository({
    required this.apiClient,
  });

  Future<List<DriverModel>> getDrivers() async {
    final response = await apiClient.get(ApiEndpoints.adminDrivers);
    return _parseDrivers(response.data);
  }

  /// Drivers with `ApprovalStatus.approved` only - used to populate the
  /// driver picker when registering/assigning a vehicle, since a vehicle
  /// must never be linked to a pending or rejected driver.
  Future<List<DriverModel>> getApprovedDrivers() async {
    final response = await apiClient.get(ApiEndpoints.approvedDrivers);
    return _parseDrivers(response.data);
  }

  Future<void> softDeleteDriver(String id) async {
    await apiClient.delete(ApiEndpoints.softDeleteDriver(id));
  }

  Future<void> restoreDriver(String id) async {
    await apiClient.put(ApiEndpoints.restoreDriver(id));
  }

  List<DriverModel> _parseDrivers(dynamic data) {
    if (data is List) {
      return data.map((e) => DriverModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
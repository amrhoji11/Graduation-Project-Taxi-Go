import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/driver_pending_model.dart';

/// Talks to `TaxiApp.Backend.Api.Controllers.DriverApprovalsController`
/// (`[Authorize(Roles = "Admin")]`, base route `api/DriverApprovals`).
///
/// All driver IDs here are the `ApplicationUser.Id` GUID (string), not an int.
class DriverApprovalsRepository {
  final ApiClient apiClient;

  DriverApprovalsRepository({
    required this.apiClient,
  });

  Future<List<DriverPendingModel>> getPendingDrivers({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.pendingDrivers,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final data = response.data;
    final driversJson = data is Map ? data['drivers'] : null;

    if (driversJson is List) {
      return driversJson
          .map((e) => DriverPendingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<void> approveDriver(String id) async {
    await apiClient.post(ApiEndpoints.approveDriver(id));
  }

  Future<void> rejectDriver(String id, {String? notes}) async {
    await apiClient.post(
      ApiEndpoints.rejectDriver(id),
      data: {
        'notes': notes,
      },
    );
  }

  Future<DriverApprovalDetailsModel> getDriverDetails(String driverId) async {
    final response = await apiClient.get(
      ApiEndpoints.driverApprovalDetails(driverId),
    );

    return DriverApprovalDetailsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}

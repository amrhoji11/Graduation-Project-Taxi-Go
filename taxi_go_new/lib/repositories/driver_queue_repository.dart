import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';

class DriverQueueRepository {
  final ApiClient apiClient;

  DriverQueueRepository({required this.apiClient});

  Future<void> enterQueue() async {
    await apiClient.post(ApiEndpoints.enterQueue);
  }

  Future<void> leaveQueue() async {
    await apiClient.post(ApiEndpoints.leaveQueue);
  }

  Future<void> returnToOffice() async {
    await apiClient.post(ApiEndpoints.returnToOffice);
  }
}

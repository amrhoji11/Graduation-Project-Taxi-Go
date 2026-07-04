import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/vehicle_model.dart';

class VehicleRepository {
  final ApiClient apiClient;

  VehicleRepository({
    required this.apiClient,
  });

  Future<List<VehicleModel>> getVehicles({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.vehicles,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    return _parseVehicleList(response.data);
  }

  Future<VehicleModel> getVehicleById(int vehicleId) async {
    final response = await apiClient.get(
      ApiEndpoints.vehicleById(vehicleId),
    );

    return VehicleModel.fromJson(_extractMap(response.data));
  }

  Future<List<VehicleModel>> getUnassignedVehicles({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.unassignedVehicles,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    return _parseVehicleList(response.data);
  }

  Future<VehicleModel> addVehicle({
    required String driverId,
    required String plateNumber,
    required String make,
    required String model,
    required String color,
    required VehicleSize vehicleSize,
    required int seats,
    int? year,
    File? plateImage,
  }) async {
    final formData = FormData.fromMap({
      'driverId': driverId,
      'plateNumber': plateNumber,
      'make': make,
      'model': model,
      'color': color,
      'vehicleSize': vehicleSize.apiValue,
      'seats': seats,
      'year': ?year,
      if (plateImage != null)
        'platePhotoImg': await MultipartFile.fromFile(
          plateImage.path,
          filename: plateImage.path.split('/').last,
        ),
    });

    final response = await apiClient.post(
      ApiEndpoints.addVehicle,
      data: formData,
    );

    return VehicleModel.fromJson(_extractMap(response.data));
  }

  /// `PUT /Vehicles/{id}/Edit` returns 204 No Content on success, so this
  /// does not parse/return an updated vehicle - call `getVehicles()` again.
  Future<void> updateVehicle({
    required int vehicleId,
    String? plateNumber,
    String? make,
    String? model,
    String? color,
    VehicleSize? vehicleSize,
    int? seats,
    int? year,
    File? plateImage,
  }) async {
    final formData = FormData.fromMap({
      'plateNumber': ?plateNumber,
      'make': ?make,
      'model': ?model,
      'color': ?color,
      if (vehicleSize != null) 'vehicleSize': vehicleSize.apiValue,
      'seats': ?seats,
      'year': ?year,
      if (plateImage != null)
        'platePhotoImg': await MultipartFile.fromFile(
          plateImage.path,
          filename: plateImage.path.split('/').last,
        ),
    });

    await apiClient.put(
      ApiEndpoints.editVehicle(vehicleId),
      data: formData,
    );
  }

  Future<void> assignVehicle({
    required int vehicleId,
    required String driverId,
  }) async {
    await apiClient.patch(
      ApiEndpoints.assignVehicle(vehicleId),
      data: {
        'driverId': driverId,
      },
    );
  }

  Future<void> unassignVehicle(int vehicleId) async {
    await apiClient.post(
      ApiEndpoints.unassignVehicle(vehicleId),
    );
  }

  Future<void> changeVehicleStatus(int vehicleId) async {
    await apiClient.patch(
      ApiEndpoints.changeVehicleStatus(vehicleId),
    );
  }

  List<VehicleModel> _parseVehicleList(dynamic data) {
    if (data is List) {
      return data
          .map((item) => VehicleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => VehicleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((item) => VehicleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;

    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }

    return {};
  }
}

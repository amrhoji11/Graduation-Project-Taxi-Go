import 'dart:io';

import 'package:dio/dio.dart';

import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/driver_profile_model.dart';
import 'package:taxi_go_new/models/driver_trip_report_model.dart';

/// Calls the driver's own profile/report endpoints on `DriversController`
/// (distinct from `DriverRepository`, which is the Admin-side driver list).
class DriverProfileRepository {
  final ApiClient apiClient;

  DriverProfileRepository({required this.apiClient});

  Future<DriverProfileModel> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.driverProfile);
    return DriverProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// `PUT /Drivers/update-profile` - `[FromForm]` on the backend, so this
  /// must be sent as multipart/form-data, not JSON.
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? address,
    bool removeAddress = false,
    bool removeProfilePhoto = false,
    File? profilePhoto,
  }) async {
    final formData = FormData.fromMap({
      'FirstName': ?firstName,
      'LastName': ?lastName,
      'Address': ?address,
      'RemoveAddress': removeAddress,
      'RemoveProfilePhoto': removeProfilePhoto,
      if (profilePhoto != null)
        'ProfilePhotoImg': await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        ),
    });

    await apiClient.put(ApiEndpoints.updateDriverProfile, data: formData);
  }

  Future<List<DriverTripReportModel>> getMyTripsReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.driverTripsReport,
      queryParameters: {
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => DriverTripReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}

import 'dart:io';

import 'package:dio/dio.dart';

import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/passenger_model.dart';
import 'package:taxi_go_new/models/passenger_trip_report_model.dart';

/// Calls the passenger's own profile endpoints on `PassengersController`
/// (`GET /Passengers/profile`, `PUT /Passengers/update-profile`).
class PassengerProfileRepository {
  final ApiClient apiClient;

  PassengerProfileRepository({required this.apiClient});

  Future<PassengerProfileModel> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.passengerProfile);
    return PassengerProfileModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// `PUT /Passengers/update-profile` - `[FromForm]` on the backend, so this
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

    await apiClient.put(ApiEndpoints.updatePassengerProfile, data: formData);
  }

  /// `GET /Passengers/trips-report` - unlike the Driver equivalent, `from`
  /// and `to` are non-nullable, required `DateTime` query params on the
  /// backend (`PassengersController.GetTripsReport`); omitting either fails
  /// ASP.NET model validation with a 400, so both are mandatory here too.
  Future<List<PassengerTripReportModel>> getTripsReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.passengerTripsReport,
      queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );

    final data = response.data;
    if (data is List) {
      return data
          .map(
            (e) => PassengerTripReportModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }
}

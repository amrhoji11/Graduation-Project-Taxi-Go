import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/admin_current_trip_model.dart';
import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/admin_order_model.dart';
import 'package:taxi_go_new/models/admin_profile_model.dart';
import 'package:taxi_go_new/models/admin_trip_model.dart';
import 'package:taxi_go_new/models/driver_model.dart';
import 'package:taxi_go_new/models/paged_result_model.dart';
import 'package:taxi_go_new/models/passenger_model.dart';
import 'package:taxi_go_new/models/top_driver_model.dart';



/// Talks to `TaxiApp.Backend.Api.Controllers.AdminController`
/// (`[Authorize(Roles = "Admin")]`, base route `api/Admin`).
class AdminRepository {
  final ApiClient apiClient;

  AdminRepository({
    required this.apiClient,
  });

  Future<AdminProfileModel> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.adminProfile);
    return AdminProfileModel.fromJson(_extractMap(response.data));
  }

  Future<void> editProfile({
    String? firstName,
    String? lastName,
    String? address,
    bool removeAddress = false,
    bool removeProfilePhoto = false,
    File? profilePhoto,
  }) async {
    final formData = FormData.fromMap({
      'firstName': ?firstName,
      'lastName': ?lastName,
      'address': ?address,
      'removeAddress': removeAddress,
      'removeProfilePhoto': removeProfilePhoto,
      if (profilePhoto != null)
        'profilePhotoImg': await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        ),
    });

    await apiClient.put(
      ApiEndpoints.editAdminProfile,
      data: formData,
    );
  }

  Future<List<PassengerModel>> getPassengers() async {
    final response = await apiClient.get(ApiEndpoints.adminPassengers);
    return _parseList(response.data, PassengerModel.fromJson);
  }

  Future<void> softDeletePassenger(String id) async {
    await apiClient.delete(ApiEndpoints.softDeletePassenger(id));
  }

  Future<void> restorePassenger(String id) async {
    await apiClient.put(ApiEndpoints.restorePassenger(id));
  }

  /// Returns the new `IsActive` value after toggling.
  Future<bool> toggleUserActive(String userId) async {
    final response = await apiClient.patch(ApiEndpoints.toggleUserActive(userId));
    return response.data == true;
  }

  /// Toggles block/unblock for [userId]. Passing [endsAt] blocks until that
  /// date; leaving it null blocks indefinitely (until unblocked again).
  /// Returns `true` if the user is now blocked, `false` if just unblocked.
  Future<bool> toggleUserBlock(String userId, {String? reason, DateTime? endsAt}) async {
    final response = await apiClient.patch(
      ApiEndpoints.toggleUserBlock(userId),
      data: {
        'reason': ?reason,
        if (endsAt != null) 'endsAt': endsAt.toIso8601String(),
      },
    );
    return response.data == true;
  }

  Future<String> manualAssignOrder({
    required int orderId,
    required String driverId,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.manualAssignOrder(orderId),
      data: {'driverId': driverId},
    );
    return response.data?.toString() ?? 'تم إرسال طلب التعيين';
  }

  Future<List<DriverModel>> getAssignableDrivers() async {
    final response = await apiClient.get(ApiEndpoints.assignableDrivers);
    return _parseList(response.data, DriverModel.fromJson);
  }

  Future<PassengerProfileModel> getPassengerProfile(String id) async {
    final response = await apiClient.get(ApiEndpoints.adminProfileById(id));
    return PassengerProfileModel.fromJson(_extractMap(response.data));
  }

  Future<PagedResultModel<AdminOrderModel>> getOrders({
    int page = 1,
    int pageSize = 10,
    OrderStatusType? status,
    String? search,
    bool? ascending,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.adminOrders,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (status != null && status != OrderStatusType.unknown)
          'status': status.index,
        if (search != null && search.isNotEmpty) 'search': search,
        'ascending': ?ascending,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      },
    );

    return PagedResultModel.fromJson(
      _extractMap(response.data),
      AdminOrderModel.fromJson,
    );
  }

  Future<PagedResultModel<AdminTripModel>> getTrips({
    int page = 1,
    int pageSize = 10,
    TripStatusType? status,
    String? search,
    bool? ascending,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.adminTrips,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (status != null && status != TripStatusType.unknown)
          'status': status.index,
        if (search != null && search.isNotEmpty) 'search': search,
        'ascending': ?ascending,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      },
    );

    return PagedResultModel.fromJson(
      _extractMap(response.data),
      AdminTripModel.fromJson,
    );
  }

  Future<List<AdminCurrentTripModel>> getCurrentTrips() async {
    final response = await apiClient.get(ApiEndpoints.adminCurrentTrips);
    return _parseList(response.data, AdminCurrentTripModel.fromJson);
  }

  Future<List<TopDriverModel>> getTopDrivers({
    int top = 5,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.topDrivers,
      queryParameters: {
        'top': top,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      },
    );

    return _parseList(response.data, TopDriverModel.fromJson);
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    if (data is List) {
      return data.map((e) => itemParser(e as Map<String, dynamic>)).toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList();
    }

    return <T>[];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return {};
  }
}

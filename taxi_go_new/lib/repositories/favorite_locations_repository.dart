import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/favorite_location_model.dart';

class FavoriteLocationsRepository {
  final ApiClient apiClient;

  FavoriteLocationsRepository({
    required this.apiClient,
  });

  Future<List<FavoriteLocationModel>> getFavoriteLocations() async {
    final response = await apiClient.get(
      ApiEndpoints.favoriteLocations,
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (e) => FavoriteLocationModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map(
            (e) => FavoriteLocationModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map(
            (e) => FavoriteLocationModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    return [];
  }

  Future<void> addFavoriteLocation(
      FavoriteLocationModel location,
      ) async {
    await apiClient.post(
      ApiEndpoints.favoriteLocations,
      data: location.toJson(),
    );
  }

  Future<void> deleteFavoriteLocation(
      int locationId,
      ) async {
    await apiClient.delete(
      ApiEndpoints.deleteFavoriteLocation(locationId),
    );
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/favorite_location_model.dart';
import 'package:taxi_go_new/repositories/favorite_locations_repository.dart';

part 'favorite_locations_state.dart';

class FavoriteLocationsCubit extends Cubit<FavoriteLocationsState> {
  final FavoriteLocationsRepository favoriteLocationsRepository;

  FavoriteLocationsCubit({
    required this.favoriteLocationsRepository,
  }) : super(const FavoriteLocationsInitial());

  Future<void> getFavoriteLocations() async {
    emit(const FavoriteLocationsLoading());

    try {
      final locations =
      await favoriteLocationsRepository.getFavoriteLocations();

      emit(
        FavoriteLocationsLoaded(
          locations: locations,
        ),
      );
    } catch (e) {
      emit(
        FavoriteLocationsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> addFavoriteLocation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    emit(const FavoriteLocationsLoading());

    try {
      final location = FavoriteLocationModel(
        id: 0,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      await favoriteLocationsRepository.addFavoriteLocation(location);

      emit(
        const FavoriteLocationsSuccess(
          message: 'Favorite location added successfully',
        ),
      );

      await getFavoriteLocations();
    } catch (e) {
      emit(
        FavoriteLocationsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteFavoriteLocation(int id) async {
    emit(const FavoriteLocationsLoading());

    try {
      await favoriteLocationsRepository.deleteFavoriteLocation(id);

      emit(
        const FavoriteLocationsSuccess(
          message: 'Favorite location deleted successfully',
        ),
      );

      await getFavoriteLocations();
    } catch (e) {
      emit(
        FavoriteLocationsFailure(
          message: e.toString(),
        ),
      );
    }
  }
}
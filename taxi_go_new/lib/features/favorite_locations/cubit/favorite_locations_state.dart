part of 'favorite_locations_cubit.dart';

abstract class FavoriteLocationsState {
  const FavoriteLocationsState();
}

class FavoriteLocationsInitial extends FavoriteLocationsState {
  const FavoriteLocationsInitial();
}

class FavoriteLocationsLoading extends FavoriteLocationsState {
  const FavoriteLocationsLoading();
}

class FavoriteLocationsLoaded extends FavoriteLocationsState {
  final List<FavoriteLocationModel> locations;

  const FavoriteLocationsLoaded({
    required this.locations,
  });
}

class FavoriteLocationsSuccess extends FavoriteLocationsState {
  final String message;

  const FavoriteLocationsSuccess({
    required this.message,
  });
}

class FavoriteLocationsFailure extends FavoriteLocationsState {
  final String message;

  const FavoriteLocationsFailure({
    required this.message,
  });
}
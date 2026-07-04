import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/features/favorite_locations/cubit/favorite_locations_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/favorite_location_model.dart';

class FavoriteLocationsScreen extends StatefulWidget {
  const FavoriteLocationsScreen({super.key});

  @override
  State<FavoriteLocationsScreen> createState() =>
      _FavoriteLocationsScreenState();
}

class _FavoriteLocationsScreenState extends State<FavoriteLocationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoriteLocationsCubit>().getFavoriteLocations();
  }

  Future<void> _refresh() async {
    await context.read<FavoriteLocationsCubit>().getFavoriteLocations();
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final latitudeController = TextEditingController(text: '0');
    final longitudeController = TextEditingController(text: '0');
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.favLocAddTitle),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.commonName,
                  ),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: l10n.commonAddress,
                  ),
                ),
                TextField(
                  controller: latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.commonLatitude,
                  ),
                ),
                TextField(
                  controller: longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.commonLongitude,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                final latitude = double.tryParse(
                  latitudeController.text.trim(),
                );
                final longitude = double.tryParse(
                  longitudeController.text.trim(),
                );

                if (name.isEmpty ||
                    address.isEmpty ||
                    latitude == null ||
                    longitude == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.favLocFillFieldsCorrectly),
                    ),
                  );
                  return;
                }

                context.read<FavoriteLocationsCubit>().addFavoriteLocation(
                  name: name,
                  address: address,
                  latitude: latitude,
                  longitude: longitude,
                );

                Navigator.pop(dialogContext);
              },
              child: Text(l10n.commonAdd),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      addressController.dispose();
      latitudeController.dispose();
      longitudeController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoriteLocationsCubit, FavoriteLocationsState>(
      listener: (context, state) {
        if (state is FavoriteLocationsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is FavoriteLocationsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.favLocTitle),
            actions: [
              IconButton(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FavoriteLocationsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is FavoriteLocationsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is FavoriteLocationsLoaded) {
      if (state.locations.isEmpty) {
        return Center(
          child: Text(l10n.favLocNoneFound),
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.locations.length,
          itemBuilder: (context, index) {
            final location = state.locations[index];

            return _FavoriteLocationCard(
              location: location,
              onDelete: () {
                context
                    .read<FavoriteLocationsCubit>()
                    .deleteFavoriteLocation(location.id);
              },
            );
          },
        ),
      );
    }

    return Center(
      child: ElevatedButton(
        onPressed: _refresh,
        child: Text(l10n.favLocLoadAction),
      ),
    );
  }
}

class _FavoriteLocationCard extends StatelessWidget {
  final FavoriteLocationModel location;
  final VoidCallback onDelete;

  const _FavoriteLocationCard({
    required this.location,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(location.name),
        subtitle: Text(
          '${location.address}\n'
              '${l10n.favLocLatPrefix} ${location.latitude}, ${l10n.favLocLngPrefix} ${location.longitude}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/trips/cubit/admin_trips_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/admin_trip_model.dart';

class AdminTripsScreen extends StatefulWidget {
  const AdminTripsScreen({super.key});

  @override
  State<AdminTripsScreen> createState() => _AdminTripsScreenState();
}

class _AdminTripsScreenState extends State<AdminTripsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminTripsCubit>().getTrips();
  }

  Future<void> _refresh() async {
    await context.read<AdminTripsCubit>().getTrips();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminTripsCubit, AdminTripsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminTrips)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminTripsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AdminTripsLoading) {
      return const AppLoading();
    }

    if (state is AdminTripsFailure) {
      return AppErrorState(message: state.message, onRetry: _refresh);
    }

    if (state is AdminTripsLoaded) {
      final trips = state.result.data;

      if (trips.isEmpty) {
        return AppEmptyState(icon: Icons.route_outlined, title: l10n.adminNoTripsFound);
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _TripCard(trip: trip);
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.route_outlined,
      title: l10n.adminNoTripsLoaded,
      actionLabel: l10n.adminLoadTrips,
      onAction: _refresh,
    );
  }
}

class _TripCard extends StatelessWidget {
  final AdminTripModel trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: trip.isActive
                ? AppColors.primaryLight
                : AppColors.surfaceMuted,
            child: Icon(
              Icons.local_taxi,
              color: trip.isActive ? AppColors.primary : AppColors.neutral,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.driverTripHash}${trip.tripId} - ${trip.driverName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.commonPassengers}: ${trip.totalPassengers}\n'
                  '${l10n.commonRating}: ${trip.tripRating.toStringAsFixed(1)} (${trip.ratingCount})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          AppStatusChip(
            label: trip.status.label,
            tone: tripStatusTone(trip.status),
          ),
        ],
      ),
    );
  }
}

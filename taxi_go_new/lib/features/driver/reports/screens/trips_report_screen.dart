import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_trip_report_model.dart';

import '../cubit/reports_cubit.dart';

class TripsReportScreen extends StatefulWidget {
  const TripsReportScreen({super.key});

  @override
  State<TripsReportScreen> createState() => _TripsReportScreenState();
}

class _TripsReportScreenState extends State<TripsReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().getTripsReport();
  }

  Future<void> _refresh() async {
    await context.read<ReportsCubit>().getTripsReport();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.driverTripsReportTitle)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ReportsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is ReportsLoading) {
      return const AppLoading();
    }

    if (state is ReportsFailure) {
      return AppErrorState(message: state.message, onRetry: _refresh);
    }

    if (state is TripsReportLoaded) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: _TripsReportContent(trips: state.trips),
      );
    }

    return AppEmptyState(
      icon: Icons.bar_chart_outlined,
      title: l10n.driverNoReportYet,
      actionLabel: l10n.driverLoadReport,
      onAction: _refresh,
    );
  }
}

class _TripsReportContent extends StatelessWidget {
  final List<DriverTripReportModel> trips;

  const _TripsReportContent({required this.trips});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int totalTrips = trips.length;

    final ratedTrips = trips.where((t) => t.rating != null).toList();
    final double averageRating = ratedTrips.isEmpty
        ? 0
        : ratedTrips.map((t) => t.rating!).reduce((a, b) => a + b) /
              ratedTrips.length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppStatRow(
          children: [
            AppStatCard(
              icon: Icons.check_circle_outline,
              value: totalTrips.toString(),
              label: l10n.reportCompletedTrips,
            ),
            AppStatCard(
              icon: Icons.star_outline,
              value: ratedTrips.isEmpty ? l10n.commonNA : averageRating.toStringAsFixed(1),
              label: l10n.driverAverageRating,
              color: Colors.amber.shade700,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (trips.isEmpty)
          AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.driverNoCompletedTripsYet,
          )
        else
          ...trips.map((trip) => _TripCard(trip: trip)),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  final DriverTripReportModel trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final duration = trip.duration;
    final durationLabel = duration == null
        ? AppLocalizations.of(context)!.commonNA
        : '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip.passengerName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (trip.rating != null)
                AppStatusChip(
                  label: '${trip.rating} ★',
                  tone: AppStatusTone.warning,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${trip.pickupLocation} → ${trip.destination}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(durationLabel, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          if (trip.comment != null && trip.comment!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '"${trip.comment}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            trip.completedAt.toLocal().toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

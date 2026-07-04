import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/passenger_reports_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/passenger_trip_report_model.dart';

/// `GET /Passengers/trips-report` requires non-nullable `from`/`to` query
/// params on the backend, so unlike the Driver report this screen always
/// has a date range selected (defaults to the last 30 days) rather than
/// loading with no filter.
class PassengerTripsReportScreen extends StatefulWidget {
  const PassengerTripsReportScreen({super.key});

  @override
  State<PassengerTripsReportScreen> createState() =>
      _PassengerTripsReportScreenState();
}

class _PassengerTripsReportScreenState
    extends State<PassengerTripsReportScreen> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _to = DateTime(now.year, now.month, now.day);
    _from = _to.subtract(const Duration(days: 30));
    _load();
  }

  void _load() {
    context.read<PassengerReportsCubit>().getTripsReport(
      from: _from,
      to: _to,
    );
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );

    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _load();
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PassengerReportsCubit, PassengerReportsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.commonMyTripsReport),
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range_outlined),
                onPressed: _pickRange,
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppStatusChip(
                    label: '${_formatDate(_from)} → ${_formatDate(_to)}',
                    tone: AppStatusTone.info,
                  ),
                ),
              ),
              Expanded(child: _buildBody(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(PassengerReportsState state) {
    if (state is PassengerReportsLoading || state is PassengerReportsInitial) {
      return const AppLoading();
    }

    if (state is PassengerReportsFailure) {
      return AppErrorState(message: state.message, onRetry: _load);
    }

    if (state is PassengerTripsReportLoaded) {
      return RefreshIndicator(
        onRefresh: () async => _load(),
        child: _TripsReportContent(trips: state.trips),
      );
    }

    return const SizedBox.shrink();
  }
}

class _TripsReportContent extends StatelessWidget {
  final List<PassengerTripReportModel> trips;

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
              label: l10n.reportAvgRatingGiven,
              color: Colors.amber.shade700,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (trips.isEmpty)
          AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.reportNoCompletedTrips,
            subtitle: l10n.reportNoDataInRange,
          )
        else
          ...trips.map((trip) => _TripCard(trip: trip)),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  final PassengerTripReportModel trip;

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
                trip.driverName,
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

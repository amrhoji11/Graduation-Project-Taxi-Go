import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/reports/cubit/admin_reports_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/top_driver_model.dart';

class AdminTopDriversScreen extends StatefulWidget {
  const AdminTopDriversScreen({super.key});

  @override
  State<AdminTopDriversScreen> createState() => _AdminTopDriversScreenState();
}

class _AdminTopDriversScreenState extends State<AdminTopDriversScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminReportsCubit>().getTopDrivers();
  }

  Future<void> _refresh() async {
    await context.read<AdminReportsCubit>().getTopDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReportsCubit, AdminReportsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminTopDrivers)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminReportsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AdminReportsLoading) {
      return const AppLoading();
    }

    if (state is AdminReportsFailure) {
      return AppErrorState(message: state.message, onRetry: _refresh);
    }

    if (state is TopDriversLoaded) {
      if (state.drivers.isEmpty) {
        return AppEmptyState(
          icon: Icons.leaderboard_outlined,
          title: l10n.adminNoDataFound,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.drivers.length,
          itemBuilder: (context, index) {
            final driver = state.drivers[index];
            return _TopDriverCard(rank: index + 1, driver: driver);
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.leaderboard_outlined,
      title: l10n.driverNoReportYet,
      actionLabel: l10n.driverLoadReport,
      onAction: _refresh,
    );
  }
}

class _TopDriverCard extends StatelessWidget {
  final int rank;
  final TopDriverModel driver;

  const _TopDriverCard({required this.rank, required this.driver});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rank <= 3
                ? Colors.amber.withValues(alpha: 0.2)
                : AppColors.primaryLight,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rank <= 3 ? Colors.amber.shade800 : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.driverName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.adminCompletedTripsLabel} ${driver.completedTrips}\n'
                  '${l10n.adminAvgRatingLabel} ${driver.avgRating.toStringAsFixed(1)} • '
                  '${l10n.adminViolationsLabel} ${driver.violationsCount}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            driver.score.toStringAsFixed(2),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

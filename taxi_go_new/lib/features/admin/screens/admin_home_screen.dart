import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/app_dashboard_tile.dart';
import 'package:taxi_go_new/features/admin/complaints/screens/admin_violations_screen.dart';
import 'package:taxi_go_new/features/admin/drivers/screens/admin_driver_approvals_screen.dart';
import 'package:taxi_go_new/features/admin/drivers/screens/admin_drivers_screen.dart';
import 'package:taxi_go_new/features/admin/orders/screens/admin_orders_screen.dart';
import 'package:taxi_go_new/features/admin/passengers/screens/admin_passengers_screen.dart';
import 'package:taxi_go_new/features/admin/profile/screens/admin_profile_screen.dart';
import 'package:taxi_go_new/features/admin/reports/screens/admin_top_drivers_screen.dart';
import 'package:taxi_go_new/features/admin/trips/screens/admin_current_trips_screen.dart';
import 'package:taxi_go_new/features/admin/trips/screens/admin_trips_screen.dart';
import 'package:taxi_go_new/features/admin/vehicles/screens/admin_vehicles_screen.dart';
import 'package:taxi_go_new/features/auth/login/login_screen.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/features/notifications/widgets/notification_badge_icon.dart';
import 'package:taxi_go_new/features/settings/cubit/settings_cubit.dart';
import 'package:taxi_go_new/features/settings/screens/settings_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().getSettings();
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthCubit>().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = <_DashboardItem>[
      _DashboardItem(l10n.adminDrivers, Icons.local_taxi, const AdminDriversScreen()),
      _DashboardItem(l10n.adminDriverApprovals, Icons.fact_check, const AdminDriverApprovalsScreen()),
      _DashboardItem(l10n.adminVehicles, Icons.directions_car, const AdminVehiclesScreen()),
      _DashboardItem(l10n.adminPassengers, Icons.people, const AdminPassengersScreen()),
      _DashboardItem(l10n.adminOrders, Icons.receipt_long, const AdminOrdersScreen()),
      _DashboardItem(l10n.adminTrips, Icons.route, const AdminTripsScreen()),
      _DashboardItem(l10n.adminCurrentTripsLive, Icons.map, const AdminCurrentTripsScreen()),
      _DashboardItem(l10n.adminTopDrivers, Icons.leaderboard, const AdminTopDriversScreen()),
      _DashboardItem(l10n.adminComplaintsViolations, Icons.report_problem, const AdminViolationsScreen()),
      _DashboardItem(l10n.passengerMyProfile, Icons.admin_panel_settings, const AdminProfileScreen()),
      _DashboardItem(l10n.settingsTitle, Icons.settings, const SettingsScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboardTitle),
        actions: [
          const NotificationBadgeIcon(),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminManageFleet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.adminFleetSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return AppDashboardGridTile(
                    icon: item.icon,
                    title: item.title,
                    onTap: () => _open(context, item.screen),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Widget screen;

  const _DashboardItem(this.title, this.icon, this.screen);
}

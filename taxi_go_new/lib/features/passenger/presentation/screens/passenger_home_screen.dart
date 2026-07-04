import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/auth/login/login_screen.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/features/notifications/widgets/notification_badge_icon.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/order_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/create_order_screen.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/order_detail_screen.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/orders_history_screen.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/passenger_profile_screen.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/passenger_trips_report_screen.dart';
import 'package:taxi_go_new/features/settings/cubit/settings_cubit.dart';
import 'package:taxi_go_new/features/settings/screens/settings_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/order_model.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrders();
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

  Future<void> _refreshOrders() async {
    await context.read<OrderCubit>().getOrders();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.passengerHomeTitle),
        actions: [
          const NotificationBadgeIcon(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PassengerProfileScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          OrderModel? activeOrder;
          if (state is OrdersLoaded) {
            for (final order in state.orders) {
              if (order.isActive) {
                activeOrder = order;
                break;
              }
            }
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (activeOrder != null) ...[
                  AppSectionHeader(title: l10n.passengerActiveTrip),
                  AppCard(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(
                            orderId: activeOrder!.orderId,
                          ),
                        ),
                      );
                      if (context.mounted) _refreshOrders();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.local_taxi, color: Colors.amber),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeOrder.pickupLocation,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              AppStatusChip(
                                label: activeOrder.status.label,
                                tone: AppStatusTone.info,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppSectionHeader(title: l10n.passengerWhatToDo),
                AppDashboardTile(
                  icon: Icons.local_taxi,
                  title: l10n.passengerBookRide,
                  subtitle: l10n.passengerBookRideSubtitle,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateOrderScreen(),
                      ),
                    );
                    if (context.mounted) _refreshOrders();
                  },
                ),
                AppDashboardTile(
                  icon: Icons.history,
                  title: l10n.passengerMyOrders,
                  subtitle: l10n.passengerMyOrdersSubtitle,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrdersHistoryScreen(),
                      ),
                    );
                    if (context.mounted) _refreshOrders();
                  },
                ),
                AppDashboardTile(
                  icon: Icons.bar_chart,
                  title: l10n.commonMyTripsReport,
                  subtitle: l10n.commonCompletedTripsSummary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PassengerTripsReportScreen(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

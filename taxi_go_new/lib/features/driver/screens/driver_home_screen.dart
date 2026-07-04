import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/auth/login/login_screen.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/features/driver/active/cubit/driver_active_state_cubit.dart';
import 'package:taxi_go_new/features/driver/active/widgets/incoming_offer_card.dart';
import 'package:taxi_go_new/features/driver/presentation/cubit/driver_queue_cubit.dart';
import 'package:taxi_go_new/features/driver/presentation/cubit/driver_trip_cubit.dart';
import 'package:taxi_go_new/features/driver/profile/cubit/driver_profile_cubit.dart';
import 'package:taxi_go_new/features/driver/profile/screens/driver_profile_screen.dart';
import 'package:taxi_go_new/features/driver/queue/screens/driver_queue_screen.dart';
import 'package:taxi_go_new/features/driver/reports/screens/trips_report_screen.dart';
import 'package:taxi_go_new/features/driver/trip_details/screens/driver_trip_details_screen.dart';
import 'package:taxi_go_new/features/notifications/widgets/notification_badge_icon.dart';
import 'package:taxi_go_new/features/settings/cubit/settings_cubit.dart';
import 'package:taxi_go_new/features/settings/screens/settings_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_active_state_model.dart';
import 'package:taxi_go_new/models/driver_model.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  late final DriverActiveStateCubit _activeStateCubit;
  bool _navigatingToTrip = false;

  @override
  void initState() {
    super.initState();
    context.read<DriverProfileCubit>().loadProfile();
    context.read<SettingsCubit>().getSettings();

    // Global for the whole driver area: starts watching for
    // `NewTripOffer` as soon as the driver lands on the Dashboard (the
    // root screen of the driver app, always mounted under whatever else
    // is pushed on top of it - Queue, Trip Details, etc) and keeps
    // watching until logout, instead of only while the Queue screen
    // happens to be the visible one.
    _activeStateCubit = context.read<DriverActiveStateCubit>();
    _activeStateCubit.startWatching();
  }

  @override
  void dispose() {
    _activeStateCubit.stopWatching();
    super.dispose();
  }

  Future<void> _goToTripDetails(DriverActiveTripModel trip) async {
    if (_navigatingToTrip) return;
    _navigatingToTrip = true;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DriverTripDetailsScreen(trip: trip)),
    );

    _navigatingToTrip = false;
    if (mounted) {
      _activeStateCubit.refresh();
    }
  }

  Future<void> _logout() async {
    await context.read<AuthCubit>().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _toggleAvailability(bool goActive) async {
    final cubit = context.read<DriverQueueCubit>();
    if (goActive) {
      await cubit.enterQueue();
    } else {
      await cubit.leaveQueue();
    }

    if (!mounted) return;
    await context.read<DriverProfileCubit>().loadProfile();
  }

  Future<void> _markReturningToOffice() async {
    await context.read<DriverQueueCubit>().returnToOffice();

    if (!mounted) return;
    await context.read<DriverProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<DriverQueueCubit, DriverQueueState>(
          listener: (context, state) {
            if (state is DriverQueueSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is DriverQueueFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<DriverActiveStateCubit, DriverActiveStateState>(
          listener: (context, state) {
            if (state is! DriverActiveStateLoaded) return;

            if (state.data.state == DriverActiveStateType.onTrip &&
                state.data.trip != null) {
              _goToTripDetails(state.data.trip!);
            }
          },
        ),
        BlocListener<DriverTripCubit, DriverTripState>(
          listener: (context, state) {
            if (state is DriverTripActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              _activeStateCubit.refresh();
            }

            if (state is DriverTripFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.driverDashboardTitle),
          actions: [
            const NotificationBadgeIcon(),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<DriverActiveStateCubit, DriverActiveStateState>(
                builder: (context, state) {
                  if (state is DriverActiveStateLoaded &&
                      state.data.state == DriverActiveStateType.offerPending &&
                      state.data.offer != null) {
                    return IncomingOfferCard(offer: state.data.offer!);
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<DriverProfileCubit, DriverProfileState>(
                builder: (context, state) {
                  final name = state is DriverProfileLoaded
                      ? state.profile.fullName
                      : 'Driver';
                  final phone = state is DriverProfileLoaded
                      ? state.profile.phoneNumber
                      : '';
                  final status = state is DriverProfileLoaded
                      ? state.profile.status
                      : DriverStatus.offline;
                  final photoUrl = state is DriverProfileLoaded
                      ? state.profile.profilePhotoUrl
                      : null;
                  final isReturningToOffice =
                      status == DriverStatus.returningToOffice;
                  final isAvailable = status == DriverStatus.available;

                  return AppCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    phone,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  AppStatusChip(
                                    label: isReturningToOffice
                                        ? l10n.driverReturningToOffice
                                        : (isAvailable ? l10n.commonActive : l10n.commonInactive),
                                    tone: driverStatusTone(status),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        BlocBuilder<DriverQueueCubit, DriverQueueState>(
                          builder: (context, queueState) {
                            final isLoading = queueState is DriverQueueLoading;

                            if (isReturningToOffice) {
                              return SizedBox(
                                width: double.infinity,
                                child: AppPrimaryButton(
                                  label: l10n.driverImBack,
                                  icon: Icons.play_circle_outline,
                                  isLoading: isLoading,
                                  onPressed: () => _toggleAvailability(true),
                                ),
                              );
                            }

                            if (isAvailable) {
                              return Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  AppSecondaryButton(
                                    label: l10n.driverGoInactive,
                                    icon: Icons.pause_circle_outline,
                                    expand: false,
                                    onPressed: isLoading
                                        ? null
                                        : () => _toggleAvailability(false),
                                  ),
                                  AppSecondaryButton(
                                    label: l10n.driverReturningToOffice,
                                    icon: Icons.home_outlined,
                                    expand: false,
                                    onPressed:
                                        isLoading ? null : _markReturningToOffice,
                                  ),
                                ],
                              );
                            }

                            return SizedBox(
                              width: double.infinity,
                              child: AppPrimaryButton(
                                label: l10n.driverGoActive,
                                icon: Icons.play_circle_outline,
                                isLoading: isLoading,
                                onPressed: () => _toggleAvailability(true),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(title: l10n.driverQuickActions),
              AppDashboardTile(
                icon: Icons.queue,
                title: l10n.driverQueueTitle,
                subtitle: l10n.driverQueueSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverQueueScreen(),
                    ),
                  );
                },
              ),
              AppDashboardTile(
                icon: Icons.directions_car,
                title: l10n.commonMyTripsReport,
                subtitle: l10n.commonCompletedTripsSummary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TripsReportScreen(),
                    ),
                  );
                },
              ),
              AppDashboardTile(
                icon: Icons.person,
                title: l10n.passengerMyProfile,
                subtitle: l10n.driverVehicleInfoSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

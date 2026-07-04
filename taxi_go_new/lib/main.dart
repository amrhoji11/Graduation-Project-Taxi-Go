import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/services/signalr_service.dart';
import 'package:taxi_go_new/core/storage/token_storage.dart';
import 'package:taxi_go_new/core/theme/app_theme.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

import 'package:taxi_go_new/features/auth/data/repositories/auth_repository.dart';
import 'package:taxi_go_new/features/auth/login/login_screen.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:taxi_go_new/features/admin/screens/admin_home_screen.dart';
import 'package:taxi_go_new/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:taxi_go_new/features/admin/vehicles/cubit/vehicle_cubit.dart';
import 'package:taxi_go_new/features/admin/profile/cubit/admin_profile_cubit.dart';
import 'package:taxi_go_new/features/admin/passengers/cubit/admin_passengers_cubit.dart';
import 'package:taxi_go_new/features/admin/orders/cubit/admin_orders_cubit.dart';
import 'package:taxi_go_new/features/admin/trips/cubit/admin_current_trips_cubit.dart';
import 'package:taxi_go_new/features/admin/trips/cubit/admin_trips_cubit.dart';
import 'package:taxi_go_new/features/admin/reports/cubit/admin_reports_cubit.dart';
import 'package:taxi_go_new/features/admin/drivers/cubit/driver_approvals_cubit.dart';
import 'package:taxi_go_new/repositories/admin_repository.dart';
import 'package:taxi_go_new/repositories/driver_approvals_repository.dart';

import 'package:taxi_go_new/features/driver/active/cubit/driver_active_state_cubit.dart';
import 'package:taxi_go_new/features/driver/presentation/cubit/driver_queue_cubit.dart';
import 'package:taxi_go_new/features/driver/presentation/cubit/driver_trip_cubit.dart';
import 'package:taxi_go_new/features/driver/profile/cubit/driver_profile_cubit.dart';
import 'package:taxi_go_new/features/driver/screens/driver_home_screen.dart';

import 'package:taxi_go_new/features/passenger/presentation/cubit/order_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/passenger_profile_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/passenger_reports_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/passenger_home_screen.dart';
import 'package:taxi_go_new/repositories/passenger_profile_repository.dart';

import 'package:taxi_go_new/features/notifications/cubit/notification_cubit.dart';
import 'package:taxi_go_new/repositories/notification_repository.dart';
import 'package:taxi_go_new/features/settings/cubit/settings_cubit.dart';
import 'package:taxi_go_new/features/complaints/cubit/complaints_cubit.dart';
import 'package:taxi_go_new/features/favorite_locations/cubit/favorite_locations_cubit.dart';
import 'package:taxi_go_new/features/realtime/cubit/realtime_trip_cubit.dart';
import 'package:taxi_go_new/features/realtime/cubit/driver_location_cubit.dart';
import 'package:taxi_go_new/repositories/favorite_locations_repository.dart';

import 'package:taxi_go_new/repositories/order_repository.dart';
import 'package:taxi_go_new/repositories/driver_repository.dart';
import 'package:taxi_go_new/repositories/driver_trip_repository.dart';
import 'package:taxi_go_new/repositories/driver_profile_repository.dart';
import 'package:taxi_go_new/repositories/vehicle_repository.dart';
import 'package:taxi_go_new/repositories/settings_repository.dart';
import 'package:taxi_go_new/repositories/complaints_repository.dart';

import 'package:taxi_go_new/features/driver/reports/cubit/reports_cubit.dart';
import 'package:taxi_go_new/repositories/driver_queue_repository.dart';

/// Trusts the backend's self-signed dev certificate, matching the bypass
/// `ApiClient` already applies to its own HttpClient - without this, the
/// SignalR WebSocket handshake (`dart:io` `WebSocket.connect`) fails with a
/// certificate error against the same dev server REST calls already trust.
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _DevHttpOverrides();

  await TokenStorage.instance.init();

  final apiClient = ApiClient();
  final signalRService = SignalRService();

  final authRepository = AuthRepository(apiClient: apiClient);
  final orderRepository = OrderRepository(apiClient: apiClient);
  final passengerProfileRepository = PassengerProfileRepository(
    apiClient: apiClient,
  );
  final driverRepository = DriverRepository(apiClient: apiClient);
  final driverTripRepository = DriverTripRepository(apiClient: apiClient);
  final driverQueueRepository = DriverQueueRepository(apiClient: apiClient);
  final driverProfileRepository = DriverProfileRepository(apiClient: apiClient);
  final vehicleRepository = VehicleRepository(apiClient: apiClient);
  final settingsRepository = SettingsRepository(apiClient: apiClient);
  final complaintsRepository = ComplaintsRepository(apiClient: apiClient);
  final favoriteLocationsRepository = FavoriteLocationsRepository(
    apiClient: apiClient,
  );
  final adminRepository = AdminRepository(apiClient: apiClient);
  final driverApprovalsRepository = DriverApprovalsRepository(
    apiClient: apiClient,
  );
  final notificationRepository = NotificationRepository(
    apiClient: apiClient,
  );

  runApp(
    TaxiGoApp(
      authRepository: authRepository,
      orderRepository: orderRepository,
      passengerProfileRepository: passengerProfileRepository,
      driverRepository: driverRepository,
      driverTripRepository: driverTripRepository,
      driverQueueRepository: driverQueueRepository,
      driverProfileRepository: driverProfileRepository,
      vehicleRepository: vehicleRepository,
      settingsRepository: settingsRepository,
      complaintsRepository: complaintsRepository,
      favoriteLocationsRepository: favoriteLocationsRepository,
      adminRepository: adminRepository,
      driverApprovalsRepository: driverApprovalsRepository,
      notificationRepository: notificationRepository,
      signalRService: signalRService,
    ),
  );
}

class TaxiGoApp extends StatelessWidget {
  final AuthRepository authRepository;
  final OrderRepository orderRepository;
  final PassengerProfileRepository passengerProfileRepository;
  final DriverRepository driverRepository;
  final DriverTripRepository driverTripRepository;
  final DriverQueueRepository driverQueueRepository;
  final DriverProfileRepository driverProfileRepository;
  final VehicleRepository vehicleRepository;
  final SettingsRepository settingsRepository;
  final ComplaintsRepository complaintsRepository;
  final FavoriteLocationsRepository favoriteLocationsRepository;
  final AdminRepository adminRepository;
  final DriverApprovalsRepository driverApprovalsRepository;
  final NotificationRepository notificationRepository;
  final SignalRService signalRService;

  const TaxiGoApp({
    super.key,
    required this.authRepository,
    required this.orderRepository,
    required this.passengerProfileRepository,
    required this.driverRepository,
    required this.driverTripRepository,
    required this.driverQueueRepository,
    required this.driverProfileRepository,
    required this.vehicleRepository,
    required this.settingsRepository,
    required this.complaintsRepository,
    required this.favoriteLocationsRepository,
    required this.adminRepository,
    required this.driverApprovalsRepository,
    required this.notificationRepository,
    required this.signalRService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository: authRepository),
        ),
        BlocProvider<OrderCubit>(
          create: (_) => OrderCubit(orderRepository: orderRepository),
        ),
        BlocProvider<PassengerProfileCubit>(
          create: (_) => PassengerProfileCubit(
            passengerProfileRepository: passengerProfileRepository,
          ),
        ),
        BlocProvider<PassengerReportsCubit>(
          create: (_) => PassengerReportsCubit(
            passengerProfileRepository: passengerProfileRepository,
          ),
        ),
        BlocProvider<AdminCubit>(
          create: (_) => AdminCubit(
            driverRepository: driverRepository,
            adminRepository: adminRepository,
          ),
        ),
        BlocProvider<DriverTripCubit>(
          create: (_) =>
              DriverTripCubit(driverTripRepository: driverTripRepository),
        ),
        BlocProvider<DriverQueueCubit>(
          create: (_) =>
              DriverQueueCubit(driverQueueRepository: driverQueueRepository),
        ),
        BlocProvider<VehicleCubit>(
          create: (_) => VehicleCubit(
            vehicleRepository: vehicleRepository,
            driverRepository: driverRepository,
          ),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(settingsRepository: settingsRepository),
        ),
        BlocProvider<ComplaintsCubit>(
          create: (_) =>
              ComplaintsCubit(complaintsRepository: complaintsRepository),
        ),
        BlocProvider<ReportsCubit>(
          create: (_) =>
              ReportsCubit(driverProfileRepository: driverProfileRepository),
        ),
        BlocProvider<DriverProfileCubit>(
          create: (_) => DriverProfileCubit(
            driverProfileRepository: driverProfileRepository,
          ),
        ),
        BlocProvider<FavoriteLocationsCubit>(
          create: (_) => FavoriteLocationsCubit(
            favoriteLocationsRepository: favoriteLocationsRepository,
          ),
        ),
        BlocProvider<AdminProfileCubit>(
          create: (_) => AdminProfileCubit(adminRepository: adminRepository),
        ),
        BlocProvider<AdminPassengersCubit>(
          create: (_) => AdminPassengersCubit(adminRepository: adminRepository),
        ),
        BlocProvider<AdminOrdersCubit>(
          create: (_) => AdminOrdersCubit(adminRepository: adminRepository),
        ),
        BlocProvider<AdminTripsCubit>(
          create: (_) => AdminTripsCubit(adminRepository: adminRepository),
        ),
        BlocProvider<AdminCurrentTripsCubit>(
          create: (_) => AdminCurrentTripsCubit(
            adminRepository: adminRepository,
            signalRService: signalRService,
          ),
        ),
        BlocProvider<AdminReportsCubit>(
          create: (_) => AdminReportsCubit(adminRepository: adminRepository),
        ),
        BlocProvider<DriverApprovalsCubit>(
          create: (_) => DriverApprovalsCubit(
            driverApprovalsRepository: driverApprovalsRepository,
          ),
        ),
        BlocProvider<NotificationCubit>(
          create: (_) =>
              NotificationCubit(notificationRepository: notificationRepository),
        ),
        BlocProvider<RealtimeTripCubit>(
          create: (_) => RealtimeTripCubit(signalRService: signalRService),
        ),
        BlocProvider<DriverLocationCubit>(
          create: (_) => DriverLocationCubit(signalRService: signalRService),
        ),
        BlocProvider<DriverActiveStateCubit>(
          create: (_) => DriverActiveStateCubit(
            driverTripRepository: driverTripRepository,
            signalRService: signalRService,
          ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final darkMode = settingsState is SettingsLoaded
              ? settingsState.settings.darkMode
              : false;

          // Drives both translated strings and RTL/LTR layout direction -
          // Material widgets automatically mirror for `ar` since it's one of
          // Flutter's built-in RTL locales, no manual Directionality needed.
          final language = settingsState is SettingsLoaded
              ? settingsState.settings.language
              : 'en';

          return MaterialApp(
            title: 'TaxiGo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppStartupRouter(),
          );
        },
      ),
    );
  }
}

class AppStartupRouter extends StatelessWidget {
  const AppStartupRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = TokenStorage.instance;

    if (!storage.isLoggedInSync) return const LoginScreen();
    if (storage.isAdmin) return const AdminHomeScreen();
    if (storage.isDriver) return const DriverHomeScreen();
    if (storage.isPassenger) return const PassengerHomeScreen();

    return const LoginScreen();
  }
}

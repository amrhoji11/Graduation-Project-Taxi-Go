import 'package:flutter/material.dart';

import 'package:taxi_go_new/core/storage/token_storage.dart';
import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_text_styles.dart';
import 'package:taxi_go_new/features/admin/screens/admin_home_screen.dart';
import 'package:taxi_go_new/features/auth/login/login_screen.dart';
import 'package:taxi_go_new/features/driver/screens/driver_home_screen.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/passenger_home_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Widget getNextScreen() {
    final storage = TokenStorage.instance;

    if (!storage.isLoggedInSync) {
      return const LoginScreen();
    }

    if (storage.isAdmin) {
      return const AdminHomeScreen();
    }

    if (storage.isDriver) {
      return const DriverHomeScreen();
    }

    if (storage.isPassenger) {
      return const PassengerHomeScreen();
    }

    return const LoginScreen();
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => getNextScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text('TaxiGo', style: AppTextStyles.brandTitle),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.splashTagline,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

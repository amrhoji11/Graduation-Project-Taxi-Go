import 'package:flutter/material.dart';

/// Central color palette for the whole app - a modern taxi/transportation
/// look (deep green primary, soft off-white surfaces). Every screen should
/// pull colors from here (or from the theme they configure) rather than
/// hardcoding `Colors.*` values, so the look stays consistent if the palette
/// ever changes.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0E7C4A);
  static const Color primaryDark = Color(0xFF0A5C37);
  static const Color primaryLight = Color(0xFFE3F3EA);
  static const Color accent = Color(0xFF2ECC71);

  static const Color background = Color(0xFFF6F9F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F3F1);

  static const Color textPrimary = Color(0xFF1A1F1C);
  static const Color textSecondary = Color(0xFF6B7770);
  static const Color divider = Color(0xFFE3E8E5);

  static const Color success = Color(0xFF0E7C4A);
  static const Color warning = Color(0xFFC8862B);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF3B7DC4);
  static const Color neutral = Color(0xFF8A93A0);

  // Dark theme surfaces.
  static const Color backgroundDark = Color(0xFF101512);
  static const Color surfaceDark = Color(0xFF1A211D);
  static const Color surfaceMutedDark = Color(0xFF222B25);
  static const Color textPrimaryDark = Color(0xFFEDF2EF);
  static const Color textSecondaryDark = Color(0xFFA7B3AC);
  static const Color dividerDark = Color(0xFF2E3A33);
}

/// Semantic meaning behind a [AppStatusChip] color - screens map their own
/// backend enum (`OrderStatusType`, `TripStatusType`, `DriverStatus`, ...)
/// onto one of these rather than the chip needing to know about every enum.
enum AppStatusTone { success, warning, error, info, neutral }

extension AppStatusToneColor on AppStatusTone {
  Color get color {
    switch (this) {
      case AppStatusTone.success:
        return AppColors.success;
      case AppStatusTone.warning:
        return AppColors.warning;
      case AppStatusTone.error:
        return AppColors.error;
      case AppStatusTone.info:
        return AppColors.info;
      case AppStatusTone.neutral:
        return AppColors.neutral;
    }
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// One-off text styles that don't come from [ThemeData.textTheme] directly
/// (e.g. the big number on a stat card). Everyday text should prefer
/// `Theme.of(context).textTheme.*` so it automatically follows light/dark
/// mode; these are for spots that need something the default text theme
/// doesn't already express.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle statValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle statValueDark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
    height: 1.1,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle brandTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.2,
  );
}

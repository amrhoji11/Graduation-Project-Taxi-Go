import 'package:flutter/material.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';

/// Small rounded status pill (e.g. order/trip/driver status). Screens
/// already compute a human-readable `.label` from their own backend enum
/// (`OrderStatusType`, `TripStatusType`, `DriverStatus`, ...) - this widget
/// just renders that label consistently, colored by the semantic
/// [AppStatusTone] the screen picks for that value.
class AppStatusChip extends StatelessWidget {
  final String label;
  final AppStatusTone tone;

  const AppStatusChip({super.key, required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final color = tone.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

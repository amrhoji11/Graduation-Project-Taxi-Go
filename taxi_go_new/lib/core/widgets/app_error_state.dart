import 'package:flutter/material.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'app_button.dart';

/// Standard error state - replaces a bare `Center(child: Text(message))`.
/// Errors are always shown (never hidden), just with a consistent,
/// presentable look and a retry action when one makes sense.
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppSecondaryButton(
                label: AppLocalizations.of(context)!.commonRetry,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

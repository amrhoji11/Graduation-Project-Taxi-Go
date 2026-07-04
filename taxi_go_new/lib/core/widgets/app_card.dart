import 'package:flutter/material.dart';

import 'package:taxi_go_new/core/theme/app_spacing.dart';

/// Standard content card - consistent padding/radius wrapper around [Card],
/// optionally tappable. Use this instead of a bare `Card(...)` so spacing
/// stays consistent across screens.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.only(bottom: AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            )
          : Padding(padding: padding, child: child),
    );

    return Padding(padding: margin, child: card);
  }
}

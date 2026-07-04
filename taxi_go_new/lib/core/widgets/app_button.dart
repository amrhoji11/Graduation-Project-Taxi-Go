import 'package:flutter/material.dart';

/// Filled primary action button - wraps [ElevatedButton] so every "main"
/// action (submit, confirm, send) looks identical and handles its own
/// loading spinner instead of every screen re-implementing that.
///
/// Defaults to full width (`expand: true`), which is what a screen's single
/// bottom CTA almost always wants. Pass `expand: false` when placing this
/// inside a `Wrap`/`Row`/`Align`, which give unbounded width - a full-width
/// child there would throw a layout error.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Outlined secondary action button - for the "cancel" / less-important
/// sibling of an [AppPrimaryButton]. Same full-width-by-default behavior.
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
          )
        : OutlinedButton(onPressed: onPressed, child: Text(label));

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

import 'package:flutter/material.dart';

/// Standard full-area loading state - replaces a bare
/// `Center(child: CircularProgressIndicator())` so loading screens look
/// the same everywhere (and can carry an optional label).
class AppLoading extends StatelessWidget {
  final String? label;

  const AppLoading({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../spacing.dart';

/// Section Card Widget
///
/// A reusable card widget for displaying navigation sections or features.
/// Provides a consistent design for section/feature cards throughout the app.
///
/// Features:
/// - Icon with theme-aware background
/// - Title and optional subtitle
/// - Navigation support (route or onTap callback)
/// - Chevron indicator for navigation
/// - Ripple effect on tap
class SectionCard extends StatelessWidget {
  /// Card title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Icon to display
  final IconData icon;

  /// Optional tap callback (used if no route is provided)
  final VoidCallback? onTap;

  /// Optional route for navigation
  final String? route;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    final handleTap = onTap ?? (route != null ? () => context.go(route!) : null);

    return Card(
      child: InkWell(
        onTap: handleTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


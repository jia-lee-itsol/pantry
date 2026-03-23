import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../spacing.dart';

/// Compact Card Widget
///
/// A reusable compact card widget for displaying features or quick actions.
/// Similar to SectionCard but with a vertical layout suitable for grid displays.
///
/// Features:
/// - Icon with theme-aware background
/// - Title and optional subtitle
/// - Navigation support (route or onTap callback)
/// - Expandable width (uses Expanded widget)
/// - Text overflow handling
class CompactCard extends StatelessWidget {
  /// Card title text
  final String title;

  /// Optional subtitle text (max 2 lines with ellipsis)
  final String? subtitle;

  /// Icon to display
  final IconData icon;

  /// Optional tap callback (used if no route is provided)
  final VoidCallback? onTap;

  /// Optional route for navigation
  final String? route;

  const CompactCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    final handleTap =
        onTap ?? (route != null ? () => context.go(route!) : null);

    return Expanded(
      child: Card(
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: AppSpacing.md),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';

// ============================================
// Summary Card Widget
// ============================================

/// Reusable summary card widget for displaying key statistics.
///
/// This widget displays a numerical summary with:
/// - Custom icon with specified color
/// - Title text
/// - Large count number
/// - Subtitle/description text
///
/// Used on the home page to show quick statistics like:
/// - Number of items expiring soon
/// - Total stockpile items count
/// - Other dashboard metrics
///
/// Visual design:
/// - Card with padding
/// - Icon and title at the top
/// - Large, bold count number
/// - Small subtitle text at the bottom
class SummaryCard extends StatelessWidget {
  /// Title text displayed next to the icon
  final String title;

  /// Main count number to display prominently
  final int count;

  /// Subtitle/description text shown below the count
  final String subtitle;

  /// Icon to display at the top
  final IconData icon;

  /// Color for the icon
  final Color iconColor;

  /// Creates a [SummaryCard].
  ///
  /// All parameters are required to ensure consistent display.
  ///
  /// Parameters:
  /// - [title]: The card title
  /// - [count]: The number to display
  /// - [subtitle]: Description text
  /// - [icon]: Icon to show
  /// - [iconColor]: Color for the icon
  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  /// Builds the summary card widget.
  ///
  /// Parameters:
  /// - [context]: The build context
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


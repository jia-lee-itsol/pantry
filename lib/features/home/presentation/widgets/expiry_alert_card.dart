import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';

// ============================================
// Expiry Alert Card Widget
// ============================================

/// Alert card widget for displaying items expiring today.
///
/// This widget shows a prominent red alert when there are items
/// in the refrigerator that are expiring on the current date.
/// It includes:
/// - Warning icon in red
/// - Count of expiring items
/// - Action button to navigate to the fridge page
///
/// The card automatically hides when count is 0, showing only
/// when user action is needed.
///
/// Visual design:
/// - Red color scheme to indicate urgency
/// - Rounded corners with border
/// - Prominent warning icon
class ExpiryAlertCard extends StatelessWidget {
  /// Number of items expiring today
  final int count;

  /// Creates an [ExpiryAlertCard].
  ///
  /// Parameters:
  /// - [count]: Number of items expiring today (required)
  const ExpiryAlertCard({
    super.key,
    required this.count,
  });

  /// Builds the expiry alert card widget.
  ///
  /// Returns an empty widget if count is 0, otherwise displays
  /// a red alert card with expiry information and action button.
  ///
  /// Parameters:
  /// - [context]: The build context
  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日期限切れの食品が$count個あります',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              context.go('/fridge');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '確認する',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.red.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


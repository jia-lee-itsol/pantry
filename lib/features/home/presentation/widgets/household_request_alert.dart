import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../household/presentation/providers/household_provider.dart';

// ============================================
// Household Request Alert Widget
// ============================================

/// Alert card widget for displaying pending household management requests.
///
/// This widget shows a blue alert when there are pending requests from
/// household members to join or share pantry management. It includes:
/// - Mail icon with badge showing pending count
/// - Message indicating number of pending requests
/// - Tap functionality to navigate to the household requests page
///
/// The card automatically hides when there are no pending requests,
/// showing only when user action is needed.
///
/// Visual design:
/// - Blue color scheme to indicate information/action needed
/// - Badge on mail icon showing count
/// - Rounded corners with border
/// - Tappable with visual feedback
///
/// This alert is typically displayed at the top of the home page
/// to ensure users see important household collaboration requests.
class HouseholdRequestAlert extends ConsumerWidget {
  const HouseholdRequestAlert({super.key});

  /// Builds the household request alert card widget.
  ///
  /// Returns an empty widget if count is 0, otherwise displays
  /// a blue alert card with request count and navigation.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: Widget ref for accessing providers
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingRequestsCountProvider);

    if (pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        context.push('/household/requests');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Badge(
              label: Text('$pendingCount'),
              child: Icon(
                Icons.mail_outline,
                color: Colors.blue.shade700,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingCount개의 공동관리 요청이 있습니다',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '탭하여 확인하기',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

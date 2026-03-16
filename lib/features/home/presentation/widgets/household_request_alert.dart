import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../household/presentation/providers/household_provider.dart';

class HouseholdRequestAlert extends ConsumerWidget {
  const HouseholdRequestAlert({super.key});

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

import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/usecases/group_fridge_items_usecase.dart';

// Re-export SortFilter from domain layer for convenience
export '../../domain/usecases/group_fridge_items_usecase.dart' show SortFilter;

class SortFilterBar extends StatelessWidget {
  final SortFilter selectedFilter;
  final void Function(SortFilter) onFilterChanged;

  const SortFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SegmentedButton<SortFilter>(
        segments: const [
          ButtonSegment<SortFilter>(
            value: SortFilter.expiryDateAsc,
            label: Text(
              '賞味期限順',
              style: TextStyle(color: Colors.black),
            ),
            icon: Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.black,
            ),
          ),
          ButtonSegment<SortFilter>(
            value: SortFilter.quantityAsc,
            label: Text(
              '数量順',
              style: TextStyle(color: Colors.black),
            ),
            icon: Icon(
              Icons.inventory,
              size: 18,
              color: Colors.black,
            ),
          ),
        ],
        selected: {selectedFilter},
        onSelectionChanged: (Set<SortFilter> newSelection) {
          onFilterChanged(newSelection.first);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';

// ============================================
// Category Segment Widget
// ============================================

/// Segment control button for category selection.
///
/// This widget provides a single segment in a segmented control,
/// typically used for switching between 'fridge' and 'stock' categories.
///
/// Features:
/// - Selected state with primary color background
/// - Unselected state with white background and border
/// - Tap interaction for selection
/// - Rounded corners
///
/// Visual design:
/// - Selected: Primary color background with white text
/// - Unselected: White background with gray border and text
/// - Bold font when selected, normal when unselected
class CategorySegment extends StatelessWidget {
  /// Label text displayed in the segment
  final String label;

  /// Whether this segment is currently selected
  final bool isSelected;

  /// Callback when the segment is tapped
  final VoidCallback onTap;

  /// Creates a [CategorySegment].
  ///
  /// Parameters:
  /// - [label]: The text to display (required)
  /// - [isSelected]: Selection state (required)
  /// - [onTap]: Tap handler (required)
  const CategorySegment({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  /// Builds the category segment widget.
  ///
  /// Parameters:
  /// - [context]: The build context
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColorSchemes.light.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColorSchemes.light.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

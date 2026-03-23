import 'package:flutter/material.dart';

/// Primary Button Widget
///
/// A reusable button widget that provides a consistent primary action button
/// throughout the application. Supports loading states with a built-in
/// progress indicator.
///
/// Features:
/// - Loading state with circular progress indicator
/// - Customizable width
/// - Disabled state when loading
/// - Theme-aware styling
class PrimaryButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Optional fixed width for the button
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}

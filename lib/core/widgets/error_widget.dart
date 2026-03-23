import 'package:flutter/material.dart';

/// Error Display Widget
///
/// A reusable error state widget that displays an error message
/// with an optional retry button. Used throughout the application
/// to handle and display error states.
///
/// Features:
/// - Error icon with theme-aware color
/// - Customizable error message
/// - Optional retry callback
class ErrorDisplayWidget extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional callback for retry action
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}


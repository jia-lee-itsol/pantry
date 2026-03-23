import 'package:flutter/material.dart';

import '../spacing.dart';
import '../color_schemes.dart';

/// App Scaffold Widget
///
/// A common scaffold widget that provides consistent layout and accessibility
/// throughout the application. All pages should use this as their base structure
/// to ensure UI consistency.
///
/// Features:
/// - Consistent padding and spacing
/// - Automatic back button handling
/// - Accessibility semantics
/// - Theme-aware styling
/// - Safe area handling
class AppScaffold extends StatelessWidget {
  /// Optional title widget for the AppBar
  final Widget? title;

  /// Main body content
  final Widget body;

  /// Optional leading widget for AppBar (defaults to back button)
  final Widget? leading;

  /// Optional action widgets for AppBar
  final List<Widget>? actions;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// Whether to extend body behind AppBar
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'App main scaffold',
      child: Scaffold(
        appBar: title != null
            ? AppBar(
                leading:
                    leading ??
                    (Navigator.canPop(context)
                        ? Semantics(
                            label: 'Back',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          )
                        : null),
                title: Semantics(
                  header: true,
                  child: title!,
                ),
                actions: actions,
              )
            : null,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        backgroundColor: AppColorSchemes.light.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: body,
          ),
        ),
        floatingActionButton: floatingActionButton != null
            ? Semantics(
                label: 'Add',
                button: true,
                child: floatingActionButton!,
              )
            : null,
      ),
    );
  }
}

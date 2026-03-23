import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';

// ============================================
// Splash Page
// ============================================

/// Splash screen page displayed during app initialization.
///
/// This page shows the app logo and a loading indicator while the app
/// initializes. After a 2-second delay, it automatically navigates to
/// the login page.
///
/// Responsibilities:
/// - Display app logo and branding
/// - Show loading indicator
/// - Navigate to login page after delay
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: '/splash',
///   builder: (context, state) => const SplashPage(),
/// ),
/// ```
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  /// Navigates to the login page after a 2-second delay.
  ///
  /// Checks if the widget is still mounted before navigation to avoid
  /// errors when navigating after the widget is disposed.
  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Image.asset(
              'assets/icons/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColorSchemes.light.primary),
            ),
          ],
        ),
      ),
    );
  }
}


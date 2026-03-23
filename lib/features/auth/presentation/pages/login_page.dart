import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/color_schemes.dart';
import '../providers/auth_provider.dart';

// ============================================
// Login Page
// ============================================

/// Login page providing social authentication options.
///
/// This page displays the app logo and provides buttons for signing in
/// with Google and Apple (on supported platforms). Upon successful
/// authentication, the user is navigated to the home screen.
///
/// Responsibilities:
/// - Display app branding and description
/// - Provide Google Sign-In option
/// - Provide Apple Sign-In option (iOS/macOS only)
/// - Handle authentication success and errors
/// - Navigate to home screen after successful login
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: '/login',
///   builder: (context, state) => const LoginPage(),
/// ),
/// ```
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final isAppleSignInAvailable = ref.watch(isAppleSignInAvailableProvider);

    return Scaffold(
      backgroundColor: AppColorSchemes.light.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Image.asset(
                  'assets/icons/logo.png',
                  width: 200,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Description text
                Text(
                  '冷蔵庫と備蓄品を管理',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColorSchemes.light.onSurface.withAlpha(178),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Google Sign-In button
                _SocialLoginButton(
                  icon: Icons.g_mobiledata,
                  label: 'Googleで始める',
                  onPressed: () => _handleGoogleSignIn(context, ref),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(height: AppSpacing.md),

                // Apple Sign-In button (iOS/macOS only)
                if (isAppleSignInAvailable)
                  _SocialLoginButton(
                    icon: Icons.apple,
                    label: 'Appleで続ける',
                    onPressed: () => _handleAppleSignIn(context, ref),
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handles the Google Sign-In button press.
  ///
  /// This method executes the Google Sign-In use case and handles
  /// success and error scenarios. On success, navigates to the home page.
  /// On error, displays an error message via SnackBar.
  ///
  /// Parameters:
  /// - [context]: The build context for navigation and UI updates
  /// - [ref]: The widget ref for accessing providers
  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    debugPrint('[LoginPage] 구글 로그인 버튼 클릭됨');
    try {
      debugPrint('[LoginPage] UseCase 가져오기 시작');
      final useCase = ref.read(signInWithGoogleUseCaseProvider);
      debugPrint('[LoginPage] UseCase 가져오기 완료');

      debugPrint('[LoginPage] UseCase 실행 시작');
      await useCase();
      debugPrint('[LoginPage] UseCase 실행 완료');

      if (context.mounted) {
        debugPrint('[LoginPage] 로그인 성공 - 홈으로 이동');
        // Navigate to home on successful login
        context.go('/');
      } else {
        debugPrint('[LoginPage] Context가 mounted되지 않음');
      }
    } catch (e, stackTrace) {
      debugPrint('[LoginPage] 구글 로그인 에러 발생');
      debugPrint('[LoginPage] 에러 타입: ${e.runtimeType}');
      debugPrint('[LoginPage] 에러 메시지: $e');
      debugPrint('[LoginPage] 스택 트레이스: $stackTrace');

      if (context.mounted) {
        // Summarize error message if too long
        final errorMessage = e.toString().length > 100
            ? 'Googleログインに失敗しました。設定を確認してください。'
            : 'Googleログインに失敗しました: ${e.toString().replaceAll('Exception: ', '')}';

        debugPrint('[LoginPage] 에러 스낵바 표시: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        debugPrint('[LoginPage] Context가 mounted되지 않아 스낵바 표시 불가');
      }
    }
  }

  /// Handles the Apple Sign-In button press.
  ///
  /// This method executes the Apple Sign-In use case and handles
  /// success and error scenarios. On success, navigates to the home page.
  /// On error, displays an error message via SnackBar.
  ///
  /// Parameters:
  /// - [context]: The build context for navigation and UI updates
  /// - [ref]: The widget ref for accessing providers
  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(signInWithAppleUseCaseProvider);
      await useCase();

      if (context.mounted) {
        // Navigate to home on successful login
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appleログインに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ============================================
// Social Login Button Widget
// ============================================

/// A customizable social login button widget.
///
/// This widget creates a full-width button with an icon and label,
/// styled according to the social provider's branding.
///
/// Properties:
/// - [icon]: The icon to display (e.g., Google or Apple icon)
/// - [label]: The button text label
/// - [onPressed]: Callback when the button is pressed
/// - [backgroundColor]: The button background color
/// - [textColor]: The text and icon color
/// - [borderColor]: Optional border color
class _SocialLoginButton extends StatelessWidget {
  /// The icon to display on the button
  final IconData icon;

  /// The text label for the button
  final String label;

  /// Callback invoked when the button is pressed
  final VoidCallback onPressed;

  /// Background color of the button
  final Color backgroundColor;

  /// Color of the text and icon
  final Color textColor;

  /// Optional border color
  final Color? borderColor;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

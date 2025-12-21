import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/color_schemes.dart';
import '../providers/auth_provider.dart';

/// 로그인 페이지
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
                // 앱 로고/아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColorSchemes.light.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.kitchen,
                    size: 64,
                    color: AppColorSchemes.light.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // 앱 이름
                Text(
                  'Pantry',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColorSchemes.light.primary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // 설명 텍스트
                Text(
                  '冷蔵庫と備蓄品を管理',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColorSchemes.light.onSurface.withAlpha(178),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // 구글 로그인 버튼
                _SocialLoginButton(
                  icon: Icons.g_mobiledata,
                  label: 'Googleで始める',
                  onPressed: () => _handleGoogleSignIn(context, ref),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(height: AppSpacing.md),
                
                // 애플 로그인 버튼 (iOS/macOS만)
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

  Future<void> _handleGoogleSignIn(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
        // 로그인 성공 시 홈으로 이동
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
        // 에러 메시지가 너무 길면 요약
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

  Future<void> _handleAppleSignIn(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final useCase = ref.read(signInWithAppleUseCaseProvider);
      await useCase();
      
      if (context.mounted) {
        // 로그인 성공 시 홈으로 이동
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

/// 소셜 로그인 버튼 위젯
class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
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


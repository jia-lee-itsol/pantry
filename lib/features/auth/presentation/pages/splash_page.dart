import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';

/// 스플래시 페이지
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

  Future<void> _navigateToLogin() async {
    // 2초 대기
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
            // 앱 로고/아이콘
            Image.asset(
              'assets/icons/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.xl),

            // 로딩 인디케이터
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColorSchemes.light.primary),
            ),
          ],
        ),
      ),
    );
  }
}


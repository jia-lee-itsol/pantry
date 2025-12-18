import 'package:flutter/material.dart';

import '../spacing.dart';
import '../color_schemes.dart';

/// 앱의 공통 스캐폴드 위젯
/// 
/// 일관된 레이아웃과 접근성을 제공합니다.
/// 모든 페이지에서 사용하는 기본 스캐폴드 구조를 제공합니다.
class AppScaffold extends StatelessWidget {
  final Widget? title;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
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
      label: '앱 메인 스캐폴드',
      child: Scaffold(
        appBar: title != null
            ? AppBar(
                leading:
                    leading ??
                    (Navigator.canPop(context)
                        ? Semantics(
                            label: '뒤로가기',
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
                label: '추가하기',
                button: true,
                child: floatingActionButton!,
              )
            : null,
      ),
    );
  }
}

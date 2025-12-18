import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/fridge/presentation/pages/fridge_list_page.dart';
import '../../features/ocr/presentation/pages/ocr_page.dart';
import '../../features/stock/presentation/pages/stock_list_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/list_page.dart';
import '../../features/home/presentation/pages/low_stock_list_page.dart';
import '../../features/home/presentation/pages/low_fridge_stock_list_page.dart';
import '../../features/home/presentation/pages/sale_items_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/category_management_page.dart';
import '../../features/recipe/presentation/pages/recipe_recommendation_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/widgets/main_navigation.dart';

/// 페이지 전환 애니메이션을 제공하는 커스텀 페이지 빌더
Page<T> _buildPageWithSlideTransition<T extends Object?>(
  Widget child,
  LocalKey key,
  String? name,
) {
  return CustomTransitionPage<T>(
    key: key,
    name: name ?? '',
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 슬라이드 및 페이드 효과
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final slideAnimation = Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// ShellRoute 내부 페이지 전환 애니메이션 (더 부드러운 효과)
Page<T> _buildShellPageWithFadeTransition<T extends Object?>(
  Widget child,
  LocalKey key,
  String? name,
) {
  return CustomTransitionPage<T>(
    key: key,
    name: name ?? '',
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // ShellRoute 내부에서는 페이드 효과만 사용
      const curve = Curves.easeInOut;
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

/// 커스텀 전환 페이지 클래스
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionsBuilder;
  final Duration transitionDuration;

  const CustomTransitionPage({
    required LocalKey key,
    required String name,
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
  }) : super(key: key, name: name);

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // 인증 상태를 watch하여 변경사항을 감지
  final authState = ref.watch(currentUserProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      
      // 스플래시 페이지는 리다이렉트하지 않음 (자체적으로 2초 후 이동)
      if (isSplash) {
        return null;
      }
      
      // 로딩 중이면 리다이렉트하지 않음
      if (authState.isLoading) {
        return null;
      }
      
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';
      
      // 로그인하지 않은 경우 로그인 페이지로 리다이렉트
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      // 로그인한 상태에서 로그인 페이지에 있으면 홈으로 리다이렉트
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // 스플래시 페이지
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          const SplashPage(),
          state.pageKey,
          state.name,
        ),
      ),
      // 로그인 페이지 (네비게이션 바 없음)
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          const LoginPage(),
          state.pageKey,
          state.name,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const HomePage(),
              state.pageKey,
              state.name,
            ),
          ),
          GoRoute(
            path: '/fridge',
            name: 'fridge',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const FridgeListPage(),
              state.pageKey,
              state.name,
            ),
          ),
          GoRoute(
            path: '/stock',
            name: 'stock',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const StockListPage(),
              state.pageKey,
              state.name,
            ),
          ),
          GoRoute(
            path: '/list',
            name: 'list',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const ListPage(),
              state.pageKey,
              state.name,
            ),
          ),
          GoRoute(
            path: '/low-stock',
            name: 'low-stock',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const LowStockListPage(),
              state.pageKey,
              state.name,
            ),
          ),
          GoRoute(
            path: '/low-fridge-stock',
            name: 'low-fridge-stock',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const LowFridgeStockListPage(),
              state.pageKey,
              state.name,
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const SettingsPage(),
              state.pageKey,
              state.name,
            ),
          ),
          GoRoute(
            path: '/recipe',
            name: 'recipe',
            pageBuilder: (context, state) => _buildShellPageWithFadeTransition(
              const RecipeRecommendationPage(),
              state.pageKey,
              state.name,
            ),
          ),
        ],
      ),
      // 네비게이션 바 없이 표시될 페이지들
      GoRoute(
        path: '/ocr',
        name: 'ocr',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          const OCRPage(),
          state.pageKey,
          state.name,
        ),
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          const MapPage(),
          state.pageKey,
          state.name,
        ),
      ),
      GoRoute(
        path: '/sale-items',
        name: 'sale-items',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          const SaleItemsPage(),
          state.pageKey,
          state.name,
        ),
      ),
      GoRoute(
        path: '/category-management',
        name: 'category-management',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          const CategoryManagementPage(),
          state.pageKey,
          state.name,
        ),
      ),
    ],
  );
});

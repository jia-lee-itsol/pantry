import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main Navigation Widget
///
/// Provides the bottom navigation bar for the main sections of the application.
/// Works with GoRouter to handle navigation between different screens.
///
/// Navigation Tabs:
/// - Home (0): Dashboard and overview
/// - Fridge (1): Refrigerator items
/// - Stock (2): Pantry/emergency stock items
/// - List (3): Shopping list
/// - Settings (4): App settings
///
/// This widget wraps the child content and adds a bottom navigation bar
/// with proper routing integration.
class MainNavigation extends StatelessWidget {
  /// The child widget to display above the navigation bar
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  /// Gets the current navigation index based on the route
  ///
  /// Parameters:
  ///   - context: Build context for accessing router state
  ///
  /// Returns: Index of the current navigation tab (0-4)
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        return 0;
      case '/fridge':
        return 1;
      case '/stock':
        return 2;
      case '/list':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  /// Handles navigation bar item taps
  ///
  /// Navigates to the appropriate route based on the tapped index.
  ///
  /// Parameters:
  ///   - context: Build context for navigation
  ///   - index: Index of the tapped navigation item
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/fridge');
        break;
      case 2:
        context.go('/stock');
        break;
      case 3:
        context.go('/list');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    // Wrap child in a Scaffold to add bottom navigation bar
    // The child already contains the Scaffold for the page content
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Semantics(
          label: 'Main navigation',
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => _onItemTapped(context, index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'ホーム',
                tooltip: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.kitchen_outlined),
                activeIcon: Icon(Icons.kitchen),
                label: '冷蔵庫',
                tooltip: '冷蔵庫',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: '備蓄品',
                tooltip: '備蓄品',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'リスト',
                tooltip: 'リスト',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: '設定',
                tooltip: '設定',
              ),
            ],
          ),
        ),
      ),
    );
  }
}


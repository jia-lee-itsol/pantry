import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

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

    // child가 Scaffold를 포함하고 있으므로, AppBar와 body를 추출해야 합니다.
    // 하지만 go_router의 ShellRoute는 이미 child를 제공하므로,
    // child를 그대로 사용하고 bottomNavigationBar를 추가하는 방식이 필요합니다.
    
    // child를 감싸는 Scaffold를 만들어서 bottomNavigationBar를 추가합니다.
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
          label: '메인 네비게이션',
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


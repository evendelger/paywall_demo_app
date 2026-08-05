import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/app/widget/app_bottom_nav_bar.dart';

/// {@template main_screen}
/// Главный экран — оболочка с табами.
///
/// Порядок роутов в [_tabs] должен совпадать с порядком элементов
/// в `AppBottomNavBar.items`.
/// {@endtemplate}
@RoutePage()
class MainShell extends StatelessWidget {
  /// {@macro main_screen}
  const MainShell({super.key});

  /// Вкладки приложения
  static const List<PageRouteInfo<void>> _tabs = [
    HomeRoute(),
    // Новая вкладка добавляется сюда и в `AppBottomNavBar.items`
  ];

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: _tabs,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          extendBody: true,
          // Панель навигации не нужна, пока вкладка одна
          bottomNavigationBar: _tabs.length > 1
              ? AppBottomNavBar(tabsRouter: tabsRouter)
              : null,
          body: child,
        );
      },
    );
  }
}

import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/home/router/home_route.dart';

/// {@template main_routes}
/// Роуты для фичи главного экрана с табами
/// {@endtemplate}
final class MainRoutes {
  const MainRoutes();

  /// Путь роута обертки главного экрана
  static const String _mainWrapperPath = '';

  /// Путь роута главного экрана
  static const String _mainPath = 'main';

  /// Метод для получения списка роутов главного экрана
  List<AutoRoute> get routes => [
    AutoRoute(
      path: _mainWrapperPath,
      page: MainWrapperRoute.page,
      children: [
        AutoRoute(
          path: _mainPath,
          page: MainRoute.page,
          initial: true,
          children: [
            // Табы главного экрана.
            // Новая вкладка добавляется сюда: `...<Feature>Routes.tabRoutes`
            ...HomeRoutes.tabRoutes,
          ],
        ),
        // Full-screen роуты от всех фич — пушатся поверх табов
        // ...<Feature>Routes.overlayRoutes,
      ],
    ),
  ];
}

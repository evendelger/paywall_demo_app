import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';

/// {@template auth_routes}
/// Роуты для фичи авторизации.
///
/// Авторизация в шаблоне необязательна: экран логина доступен по прямому
/// переходу (`context.router.push(const LoginRoute())`), но приложение
/// стартует сразу на главном экране. Чтобы сделать вход обязательным,
/// см. `AppRoutes.root` и `AuthGuard`.
/// {@endtemplate}
abstract final class AuthRoutes {
  /// Путь роута логина
  static const String _loginRoutePath = '/auth/login';

  /// Метод для получения списка роутов авторизации
  static List<AutoRoute> get routes => [
    AutoRoute(
      path: _loginRoutePath,
      page: LoginRoute.page,
      // transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
  ];
}

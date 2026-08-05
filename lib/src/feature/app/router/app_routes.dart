import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/app/router/main_routes.dart';

/// {@template app_routes}
/// Корневой роут приложения.
///
/// По умолчанию авторизация необязательна — приложение стартует сразу
/// на главном экране. Чтобы сделать вход обязательным, повесьте
/// `AuthGuard` на нужную ветку (см. пример ниже) и передайте в него
/// `AuthBloc` через `AuthScope.blocOf(context)`.
/// {@endtemplate}
final class AppRoutes {
  /// {@macro app_routes}
  const AppRoutes();

  /// Метод для получения корневого роута приложения
  AutoRoute get root => AutoRoute(
    path: '/',
    page: AppWrapperRoute.page,
    // Требовать авторизацию для всего приложения:
    // guards: [AuthGuard(authBloc)],
    children: [
      // Вложенные ветки: Главный экран
      ...const MainRoutes().routes,
    ],
  );
}

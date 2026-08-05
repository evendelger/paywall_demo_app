import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/app/router/main_routes.dart';

/// {@template app_routes}
/// Корневой роут приложения — всё, что доступно **после** входного барьера.
///
/// Ветка `/` закрыта гардами: они решают, попадёт ли пользователь внутрь
/// или его развернут на онбординг либо пейвол. Сами гарды собираются
/// в `AppConfiguration` и приходят сюда через `AppRouter`.
///
/// Экраны самого барьера (`/onboarding`, `/paywall`, `/auth/login`) лежат
/// плоскими роутами рядом, а не здесь, и это принципиально: роут внутри `/`
/// сначала проходит гарды этой ветки, поэтому пейвол под гардом подписки
/// разворачивал бы сам себя — редирект зациклился бы. Плюс за барьером не
/// должна строиться оболочка с табами и подниматься `UserScope`.
///
/// Авторизация в этом приложении необязательна — неавторизованный
/// пользователь остаётся гостем. Чтобы сделать вход обязательным, добавьте
/// в список `AuthGuard(authBloc)` (`AuthScope.blocOf(context)`).
/// {@endtemplate}
final class AppRoutes {
  /// {@macro app_routes}
  const AppRoutes({this.guards = const []});

  /// Гарды ветки `/`, в порядке проверки
  final List<AutoRouteGuard> guards;

  /// Метод для получения корневого роута приложения
  AutoRoute get root => AutoRoute(
    path: '/',
    page: AppWrapperRoute.page,
    guards: guards,
    children: [
      // Вложенные ветки: Главный экран
      ...const MainRoutes().routes,
    ],
  );
}

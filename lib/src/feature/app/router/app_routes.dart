import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/app/router/main_routes.dart';

/// {@template app_routes}
/// Корневой роут приложения.
///
/// Ветка `/` закрыта гардами: они решают, попадёт ли пользователь в
/// приложение или его развернут на онбординг либо пейвол. Сами гарды
/// собираются в `AppConfiguration` и приходят сюда через `AppRouter`.
///
/// Авторизация при этом необязательна — приложение стартует на главном
/// экране, а неавторизованный пользователь остаётся гостем. Чтобы сделать
/// вход обязательным, добавьте в список `AuthGuard(authBloc)`
/// (`AuthScope.blocOf(context)`).
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

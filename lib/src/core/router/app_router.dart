import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/feature/app/router/app_routes.dart';
import 'package:paywall_demo/src/feature/auth/router/auth_routes.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Screen|Page|Shell|Sheet,Route',
)
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<AutoRoute> get routes => [
    ...AuthRoutes.routes,

    const AppRoutes().root,
  ];
}

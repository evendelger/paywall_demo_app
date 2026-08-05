import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/feature/app/router/app_routes.dart';
import 'package:paywall_demo/src/feature/auth/router/auth_routes.dart';
import 'package:paywall_demo/src/feature/onboarding/router/onboarding_routes.dart';
import 'package:paywall_demo/src/feature/subscription/router/subscription_routes.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Screen|Page|Shell|Sheet,Route',
)
class AppRouter extends RootStackRouter {
  AppRouter({this.rootGuards = const []});

  /// Гарды ветки `/`. Собираются в `AppConfiguration`: там доступны
  /// состояния, на которые они опираются.
  ///
  /// Плоские роуты (`/auth/login`, `/onboarding`, `/paywall`) гардами
  /// не закрыты — иначе редирект зациклится.
  final List<AutoRouteGuard> rootGuards;

  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<AutoRoute> get routes => [
    ...AuthRoutes.routes,
    ...OnboardingRoutes.routes,
    ...SubscriptionRoutes.routes,

    AppRoutes(guards: rootGuards).root,
  ];
}

import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';

/// {@template onboarding_routes}
/// Роуты онбординга.
///
/// Плоский корневой роут, а не вкладка: онбординг показывается до входа
/// в приложение, и оболочка с табами под ним строиться не должна.
/// {@endtemplate}
abstract final class OnboardingRoutes {
  /// Путь роута онбординга
  static const String _onboardingPath = '/onboarding';

  /// Метод для получения списка роутов онбординга
  static List<AutoRoute> get routes => [
    AutoRoute(
      path: _onboardingPath,
      page: OnboardingRoute.page,
    ),
  ];
}

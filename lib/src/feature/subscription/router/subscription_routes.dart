import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';

/// {@template subscription_routes}
/// Роуты подписки.
///
/// Пейвол — плоский корневой роут, а не вкладка: он показывается до входа
/// в приложение, и оболочка с табами под ним строиться не должна.
/// {@endtemplate}
abstract final class SubscriptionRoutes {
  /// Путь пейвола
  static const String _paywallPath = '/paywall';

  /// Метод для получения списка роутов подписки
  static List<AutoRoute> get routes => [
    AutoRoute(
      path: _paywallPath,
      page: PaywallRoute.page,
    ),
  ];
}

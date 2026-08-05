import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/subscription/bloc/subscription_bloc.dart';

/// {@template subscription_guard}
/// Гард, не пускающий в приложение без активной подписки.
///
/// Висит на ветке `/` следом за `OnboardingGuard` (см. `AppRoutes.root`).
/// Разворот делается через `redirectUntil`: навигация в `/` остаётся
/// отложенной, а пейвол снимается со стека, когда покупка сохранится
/// и экран вызовет `context.router.reevaluateGuards()`.
/// {@endtemplate}
final class SubscriptionGuard extends AutoRouteGuard {
  /// {@macro subscription_guard}
  const SubscriptionGuard(this._bloc);

  final SubscriptionBloc _bloc;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_bloc.state.isActive) {
      resolver.next();
    } else {
      resolver.redirectUntil(const PaywallRoute());
    }
  }
}

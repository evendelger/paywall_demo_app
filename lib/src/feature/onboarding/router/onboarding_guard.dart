import 'package:auto_route/auto_route.dart';

import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';

/// {@template onboarding_guard}
/// Гард, не пускающий в приложение, пока не пройден онбординг.
///
/// Висит на ветке `/` (см. `AppRoutes.root`). Разворот делается через
/// `redirectUntil`: навигация в `/` остаётся отложенной, а сам онбординг
/// снимается со стека, когда экран сохранит флаг и вызовет
/// `context.router.reevaluateGuards()`.
/// {@endtemplate}
final class OnboardingGuard extends AutoRouteGuard {
  /// {@macro onboarding_guard}
  const OnboardingGuard(this._cubit);

  final OnboardingCubit _cubit;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_cubit.state.isPassed) {
      resolver.next();
    } else {
      resolver.redirectUntil(const OnboardingRoute());
    }
  }
}

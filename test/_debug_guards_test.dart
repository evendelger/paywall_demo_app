import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/feature/home/view/home_screen.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';
import 'package:paywall_demo/src/feature/onboarding/router/onboarding_guard.dart';
import 'package:paywall_demo/src/feature/onboarding/view/onboarding_screen.dart';
import 'package:paywall_demo/src/feature/subscription/bloc/subscription_bloc.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';
import 'package:paywall_demo/src/feature/subscription/router/subscription_guard.dart';
import 'package:paywall_demo/src/feature/subscription/view/paywall_screen.dart';

import 'helpers/helpers.dart';

class _TestRouter extends RootStackRouter {
  _TestRouter(this.rootGuards);

  final List<AutoRouteGuard> rootGuards;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/onboarding', page: OnboardingRoute.page),
    AutoRoute(path: '/paywall', page: PaywallRoute.page),
    AutoRoute(path: '/', page: HomeRoute.page, guards: rootGuards),
  ];
}

void main() {
  testWidgets('полный круг флоу через гарды', (tester) async {
    final onboarding = OnboardingCubit(repository: FakeOnboardingRepository());
    final subscription = SubscriptionBloc(
      subscriptionRepository: FakeSubscriptionRepository(),
    );
    addTearDown(onboarding.close);
    addTearDown(subscription.close);

    final router = _TestRouter([
      OnboardingGuard(onboarding),
      SubscriptionGuard(subscription),
    ]);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<OnboardingCubit>.value(value: onboarding),
          BlocProvider<SubscriptionBloc>.value(value: subscription),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Чистый старт
    expect(find.byType(OnboardingScreen), findsOneWidget, reason: 'старт');

    // 2. Онбординг пройден: reevaluateGuards зовёт сам экран
    await onboarding.complete();
    await tester.pumpAndSettle();
    expect(find.byType(PaywallScreen), findsOneWidget, reason: 'после онбординга');

    // 3. Подписка куплена: reevaluateGuards зовёт SubscriptionListener
    subscription.add(
      SubscriptionEvent.applyStatus(
        status: SubscriptionStatus.purchased(SubscriptionPlan.yearly),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget, reason: 'после покупки');

    // 4. Сброс подписки с главного экрана
    subscription.add(const SubscriptionEvent.reset());
    await pumpEventQueue();
    await router.reevaluateGuards();
    await tester.pumpAndSettle();
    expect(find.byType(PaywallScreen), findsOneWidget, reason: 'сброс подписки');

    // Возвращаемся на главный: снова через SubscriptionListener
    subscription.add(
      SubscriptionEvent.applyStatus(
        status: SubscriptionStatus.purchased(SubscriptionPlan.yearly),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget, reason: 'обратно на главный');

    // 5. Сброс онбординга с главного экрана — вот здесь баг
    await onboarding.reset();
    await router.reevaluateGuards();
    await tester.pumpAndSettle();
    expect(
      find.byType(OnboardingScreen),
      findsOneWidget,
      reason: 'сброс онбординга',
    );
  });
}

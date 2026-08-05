import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/router/app_router.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';
import 'package:paywall_demo/src/feature/onboarding/router/onboarding_guard.dart';
import 'package:paywall_demo/src/feature/onboarding/view/onboarding_screen.dart';
import 'package:paywall_demo/src/feature/subscription/bloc/subscription_bloc.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';
import 'package:paywall_demo/src/feature/subscription/router/subscription_guard.dart';
import 'package:paywall_demo/src/feature/subscription/view/paywall_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('SubscriptionGuard', () {
    testWidgets('разворачивает старт приложения на пейвол, '
        'пока подписки нет', (tester) async {
      final app = await _pumpApp(tester, isOnboardingPassed: true);

      expect(find.byType(PaywallScreen), findsOneWidget);

      await app.dispose();
    });

    testWidgets('не перебивает онбординг: гарды проверяются по порядку', (
      tester,
    ) async {
      // Подписка есть, но онбординг не пройден — первым решает OnboardingGuard
      final app = await _pumpApp(
        tester,
        isOnboardingPassed: false,
        status: _activeStatus,
      );

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(PaywallScreen), findsNothing);

      await app.dispose();
    });
  });
}

/// Активная подписка «куплена только что»
final SubscriptionStatus _activeStatus = SubscriptionStatus(
  plan: SubscriptionPlan.yearly,
  purchasedAt: DateTime.now(),
  expiresAt: DateTime.now().add(const Duration(days: 30)),
);

/// Поднятое в тесте приложение: состояния и роутер живут ровно столько,
/// сколько идёт тест
class _App {
  const _App({
    required this.onboardingCubit,
    required this.subscriptionBloc,
    required this.router,
  });

  final OnboardingCubit onboardingCubit;

  final SubscriptionBloc subscriptionBloc;

  final AppRouter router;

  /// Закрывать блоки нужно **в теле теста**, а не в `addTearDown`.
  ///
  /// Колбэки teardown выполняются уже вне зоны `FakeAsync`, которой
  /// `testWidgets` подменяет время: микротаска закрытия стрима туда попадает,
  /// но прокрутить её больше некому — `close()` не завершается никогда, а
  /// таймаут самого теста к этому моменту тоже снят.
  Future<void> dispose() async {
    await onboardingCubit.close();
    await subscriptionBloc.close();

    router.dispose();
  }
}

Future<_App> _pumpApp(
  WidgetTester tester, {
  required bool isOnboardingPassed,
  SubscriptionStatus status = SubscriptionStatus.inactive,
}) async {
  final onboardingCubit = OnboardingCubit(
    repository: FakeOnboardingRepository(isPassed: isOnboardingPassed),
  );
  final subscriptionBloc = SubscriptionBloc(
    subscriptionRepository: FakeSubscriptionRepository(status: status),
  );

  final router = AppRouter(
    rootGuards: [
      OnboardingGuard(onboardingCubit),
      SubscriptionGuard(subscriptionBloc),
    ],
  );

  await tester.pumpWidget(
    // Состояния выше роутера: гарды смотрят на них до построения экранов
    MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        BlocProvider<SubscriptionBloc>.value(value: subscriptionBloc),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router.config(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _App(
    onboardingCubit: onboardingCubit,
    subscriptionBloc: subscriptionBloc,
    router: router,
  );
}

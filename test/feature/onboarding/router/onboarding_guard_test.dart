import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/router/app_router.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';
import 'package:paywall_demo/src/feature/onboarding/router/onboarding_guard.dart';
import 'package:paywall_demo/src/feature/onboarding/view/onboarding_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('OnboardingGuard', () {
    testWidgets('разворачивает старт приложения на онбординг, '
        'пока флаг не выставлен', (tester) async {
      final cubit = OnboardingCubit(repository: FakeOnboardingRepository());
      addTearDown(cubit.close);

      final router = AppRouter(rootGuards: [OnboardingGuard(cubit)]);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        // Кубит выше роутера: гард смотрит на него до построения экранов
        BlocProvider<OnboardingCubit>.value(
          value: cubit,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router.config(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}

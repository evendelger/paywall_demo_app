import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';
import 'package:paywall_demo/src/feature/onboarding/model/onboarding_page_data.dart';
import 'package:paywall_demo/src/feature/onboarding/view/onboarding_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ru'));
  final pages = OnboardingPageData.pages;

  group('OnboardingScreen', () {
    testWidgets('показывает первую страницу и кнопку «Далее»', (tester) async {
      await _pumpScreen(tester);

      expect(find.text(pages.first.title(l10n)), findsOneWidget);
      expect(_buttonTitle(tester), l10n.actionNext);
    });

    testWidgets('«Далее» листает на последнюю страницу, где кнопка меняется '
        'на «Продолжить»', (tester) async {
      await _pumpScreen(tester);

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.text(pages.last.title(l10n)), findsOneWidget);
      expect(_buttonTitle(tester), l10n.actionContinue);
    });
  });
}

Future<void> _pumpScreen(WidgetTester tester) => tester.pumpApp(
  BlocProvider<OnboardingCubit>(
    create: (context) => OnboardingCubit(
      repository: FakeOnboardingRepository(),
    ),
    child: const OnboardingScreen(),
  ),
);

/// Заголовок кнопки берётся из виджета, а не из текста на экране:
/// `AppButton` рендерит его в верхнем регистре
String _buttonTitle(WidgetTester tester) =>
    tester.widget<AppButton>(find.byType(AppButton)).title;

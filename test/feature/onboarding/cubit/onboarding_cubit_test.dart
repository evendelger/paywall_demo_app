import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('OnboardingCubit', () {
    test('начальное состояние поднимается из репозитория синхронно', () {
      // На это состояние опирается OnboardingGuard при первой проверке
      final passed = OnboardingCubit(
        repository: FakeOnboardingRepository(isPassed: true),
      );
      final notPassed = OnboardingCubit(
        repository: FakeOnboardingRepository(),
      );

      addTearDown(passed.close);
      addTearDown(notPassed.close);

      expect(passed.state.isPassed, isTrue);
      expect(notPassed.state.isPassed, isFalse);
    });

    test('complete сохраняет флаг и эмитит новое состояние', () async {
      final repository = FakeOnboardingRepository();
      final cubit = OnboardingCubit(repository: repository);
      addTearDown(cubit.close);

      final states = <OnboardingState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.complete();
      await pumpEventQueue();

      expect(repository.isPassed, isTrue);
      expect(states, [const OnboardingState(isPassed: true)]);
    });

    test('повторный complete не эмитит лишних состояний', () async {
      final cubit = OnboardingCubit(
        repository: FakeOnboardingRepository(isPassed: true),
      );
      addTearDown(cubit.close);

      final states = <OnboardingState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.complete();
      await pumpEventQueue();

      expect(states, isEmpty);
    });

    test('reset возвращает состояние к непройденному', () async {
      final repository = FakeOnboardingRepository(isPassed: true);
      final cubit = OnboardingCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.reset();

      expect(repository.isPassed, isFalse);
      expect(cubit.state.isPassed, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/feature/onboarding/data/repository/onboarding_repository.dart';
import 'package:paywall_demo/src/feature/onboarding/database/onboarding_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingRepository', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('на чистой установке онбординг не пройден', () async {
      final repository = await _createRepository();

      expect(repository.isPassed, isFalse);
    });

    test('флаг читается из хранилища, а не из объекта репозитория', () async {
      await (await _createRepository()).setPassed(isPassed: true);

      // Новый репозиторий поверх того же хранилища — как после перезапуска
      final restored = await _createRepository();

      expect(restored.isPassed, isTrue);
    });

    test('сброс возвращает состояние к непройденному', () async {
      final repository = await _createRepository();

      await repository.setPassed(isPassed: true);
      await repository.setPassed(isPassed: false);

      expect(repository.isPassed, isFalse);
    });
  });
}

Future<IOnboardingRepository> _createRepository() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return OnboardingRepository(
    onboardingDao: OnboardingDao(sharedPreferences: sharedPreferences),
  );
}

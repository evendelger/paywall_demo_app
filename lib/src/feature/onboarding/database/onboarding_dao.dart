import 'package:paywall_demo/src/core/database/shared_preferences/typed_preferences_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template onboarding_dao}
/// Хранилище состояния онбординга в `SharedPreferences`.
/// {@endtemplate}
abstract class IOnboardingDao {
  /// Пройден ли онбординг
  PreferencesEntry<bool> get isPassed;
}

/// {@macro onboarding_dao}
final class OnboardingDao extends TypedPreferencesDao
    implements IOnboardingDao {
  /// {@macro onboarding_dao}
  OnboardingDao({required SharedPreferences sharedPreferences})
    : super(sharedPreferences, name: 'onboarding');

  @override
  PreferencesEntry<bool> get isPassed => boolEntry('is_passed');
}

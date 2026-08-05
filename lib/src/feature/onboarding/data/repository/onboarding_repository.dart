import 'package:paywall_demo/src/feature/onboarding/database/onboarding_dao.dart';

/// {@template onboarding_repository}
/// Репозиторий состояния онбординга.
/// {@endtemplate}
abstract interface class IOnboardingRepository {
  /// Пройден ли онбординг.
  ///
  /// Читается синхронно: значение нужно `OnboardingGuard` в момент первой
  /// навигации, когда ждать асинхронную загрузку уже некогда.
  bool get isPassed;

  /// Сохранить состояние прохождения онбординга
  Future<void> setPassed({required bool isPassed});
}

/// {@macro onboarding_repository}
final class OnboardingRepository implements IOnboardingRepository {
  /// {@macro onboarding_repository}
  const OnboardingRepository({required this._onboardingDao});

  final IOnboardingDao _onboardingDao;

  @override
  bool get isPassed => _onboardingDao.isPassed.value ?? false;

  @override
  Future<void> setPassed({required bool isPassed}) =>
      _onboardingDao.isPassed.setValue(isPassed);
}

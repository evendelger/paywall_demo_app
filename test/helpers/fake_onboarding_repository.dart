import 'package:paywall_demo/src/feature/onboarding/data/repository/onboarding_repository.dart';

/// Репозиторий онбординга в памяти — без `SharedPreferences`
final class FakeOnboardingRepository implements IOnboardingRepository {
  FakeOnboardingRepository({this._isPassed = false});

  bool _isPassed;

  @override
  bool get isPassed => _isPassed;

  @override
  Future<void> setPassed({required bool isPassed}) async {
    _isPassed = isPassed;
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:paywall_demo/src/feature/onboarding/data/repository/onboarding_repository.dart';

part 'onboarding_cubit.freezed.dart';
part 'onboarding_state.dart';

/// {@template onboarding_cubit}
/// Состояние прохождения онбординга.
///
/// Начальное состояние поднимается из репозитория синхронно — на него
/// опирается `OnboardingGuard` при первой проверке, до первого кадра.
/// {@endtemplate}
class OnboardingCubit extends Cubit<OnboardingState> {
  /// {@macro onboarding_cubit}
  OnboardingCubit({required IOnboardingRepository repository})
    : _repository = repository,
      super(OnboardingState(isPassed: repository.isPassed));

  final IOnboardingRepository _repository;

  /// Пометить онбординг пройденным
  Future<void> complete() async {
    if (state.isPassed) return;

    await _repository.setPassed(isPassed: true);
    emit(const OnboardingState(isPassed: true));
  }

  /// Сбросить состояние — чтобы пройти флоу заново
  Future<void> reset() async {
    if (!state.isPassed) return;

    await _repository.setPassed(isPassed: false);
    emit(const OnboardingState(isPassed: false));
  }
}

part of 'onboarding_cubit.dart';

/// {@template onboarding_state}
/// Состояние онбординга.
/// {@endtemplate}
@freezed
abstract class OnboardingState with _$OnboardingState {
  /// {@macro onboarding_state}
  const factory OnboardingState({
    required bool isPassed,
  }) = _OnboardingState;

  const OnboardingState._();
}

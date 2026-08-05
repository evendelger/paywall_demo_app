part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.getData() = _SettingsEventGetData;

  const factory SettingsEvent.setTheme({
    required AppThemeType themeType,
  }) = _SettingsEventSetTheme;

  const factory SettingsEvent.setOnboardingPassed({
    required bool isPassed,
  }) = _SettingsEventSetOnboardingPassed;

  const factory SettingsEvent.incrementEntryCount() =
      _SettingsEventIncrementEntryCount;
}

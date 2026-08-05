part of 'settings_bloc.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState.idle({
    required SettingsData data,
  }) = SettingsStateIdle;

  const factory SettingsState.loading({
    required SettingsData data,
  }) = SettingsStateLoading;

  const factory SettingsState.appNeedToUpdate({
    required SettingsData data,
  }) = SettingsStateRequiredToUpdate;

  const factory SettingsState.error({
    required SettingsData data,
    String? message,
  }) = SettingsStateError;
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:paywall_demo/src/feature/settings/data/repository/settings_repository.dart';
import 'package:paywall_demo/src/feature/settings/enum/theme_type.dart';
import 'package:paywall_demo/src/feature/settings/model/settings_data.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required ISettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(SettingsState.idle(data: settingsRepository.defaultData)) {
    on<_SettingsEventSetTheme>(_setTheme);
    on<_SettingsEventIncrementEntryCount>(_incrementEntryCount);
    on<_SettingsEventGetData>(_getData);
  }

  final ISettingsRepository _settingsRepository;

  Future<void> _setTheme(
    _SettingsEventSetTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final data = state.data.copyWith(themeType: event.themeType);
    await _settingsRepository.setTheme(event.themeType);
    emit(state.copyWith(data: data));
  }

  Future<void> _incrementEntryCount(
    _SettingsEventIncrementEntryCount event,
    Emitter<SettingsState> emit,
  ) async {
    final newValue = state.data.entryCount + 1;
    await _settingsRepository.setEntry(newValue);
    final data = state.data.copyWith(entryCount: newValue);
    emit(state.copyWith(data: data));
  }

  Future<void> _getData(
    _SettingsEventGetData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsState.loading(data: state.data));

    final data = await _settingsRepository.getData();

    if (data.isUpdateAvailable) {
      emit(SettingsState.appNeedToUpdate(data: data));
    }

    return emit(SettingsState.idle(data: data));
  }
}

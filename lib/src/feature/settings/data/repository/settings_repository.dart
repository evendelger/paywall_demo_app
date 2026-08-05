import 'package:client_api/client_api.dart';
import 'package:paywall_demo/src/core/utils/device_app_info_service.dart';
import 'package:paywall_demo/src/core/utils/logger.dart';
import 'package:paywall_demo/src/feature/settings/database/settings_dao.dart';
import 'package:paywall_demo/src/feature/settings/enum/theme_type.dart';
import 'package:paywall_demo/src/feature/settings/model/settings_data.dart';

abstract interface class ISettingsRepository {
  SettingsData get defaultData;

  Future<SettingsData> getData();

  Future<void> setTheme(AppThemeType value);

  Future<void> setEntry(int value);

  Future<void> setOnboardingPassed({required bool isPassed});
}

final class SettingsRepository implements ISettingsRepository {
  SettingsRepository({
    required this._settingsDao,
    required ClientApi client,
  });

  final ISettingsDao _settingsDao;

  @override
  Future<void> setTheme(AppThemeType value) =>
      _settingsDao.themeMode.setValue(value.name);

  @override
  Future<void> setEntry(int value) => _settingsDao.entryCount.setValue(value);

  @override
  Future<SettingsData> getData() async {
    final appInfo = await DeviceAppInfoService.fetchAppDeviceInfo();
    // final response = await _client.getConfig();
    try {
      return defaultData.copyWith(
        appInfo: appInfo,
        // config: response.data?.toDomain(),
      );
    } on Object catch (e) {
      mainTalker.error(e);
      rethrow;
    }
  }

  @override
  SettingsData get defaultData {
    final themeMode = _settingsDao.themeMode.value;
    final entryCount = _settingsDao.entryCount.value;
    // В приложении онбординг появляется всегда перед авторизацией
    // final isOnboardingPassed = _settingsDao.isOnboardingPassed.value;

    return SettingsData(
      themeType: themeMode == null
          ? AppThemeType.system
          : AppThemeType.values.byName(themeMode),
      entryCount: entryCount ?? 0,
      isOnboardingPassed: true,
    );
  }

  @override
  Future<void> setOnboardingPassed({required bool isPassed}) =>
      _settingsDao.isOnboardingPassed.setValue(isPassed);
}

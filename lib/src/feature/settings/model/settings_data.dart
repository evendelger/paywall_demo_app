import 'package:paywall_demo/src/feature/settings/enum/theme_type.dart';
import 'package:paywall_demo/src/feature/settings/model/app_device_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

part 'settings_data.freezed.dart';

@freezed
abstract class SettingsData with _$SettingsData {
  const factory SettingsData({
    required AppThemeType themeType,
    required bool isOnboardingPassed,
    @Default(0) int entryCount,
    AppDeviceInfo? appInfo,
    AppConfig? config,
  }) = _SettingsData;

  const SettingsData._();

  Version? get storeVersion {
    final strVer = config?.app?.version;
    if (strVer == null) return null;
    return Version.parse(strVer);
  }

  Version? get appVersion {
    final strVer = appInfo?.appVersion;
    if (strVer == null) return null;
    return Version.parse(strVer);
  }

  /// True if store version is greater than app version
  bool get isUpdateAvailable {
    if (storeVersion == null || appVersion == null) return false;

    return storeVersion! > appVersion!;
  }
}

@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    required List<FileItem> files,
    AppInfo? app,
  }) = _AppConfig;

  const AppConfig._();
}

@freezed
abstract class AppInfo with _$AppInfo {
  const factory AppInfo({
    String? version,
    bool? forceUpdate,
    String? about,
  }) = _AppInfo;

  const AppInfo._();
}

@freezed
abstract class FileItem with _$FileItem {
  const factory FileItem({
    required String url,
    required String name,
  }) = _FileItem;

  const FileItem._();
}

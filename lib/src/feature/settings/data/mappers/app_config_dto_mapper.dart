import 'package:client_api/client_api.dart';
import 'package:paywall_demo/src/feature/settings/model/settings_data.dart';

extension AppConfigApiMapper on AppConfigDto {
  AppConfig toDomain() {
    return AppConfig(
      app: app?.toDomain(),
      files: files.map((f) => f.toDomain()).toList(),
    );
  }
}

extension AppInfoApiMapper on AppInfoDto {
  AppInfo toDomain() {
    return AppInfo(
      version: version,
      forceUpdate: forceUpdate,
      about: about,
    );
  }
}

extension FileItemApiMapper on FileItemDto {
  FileItem toDomain() {
    return FileItem(
      url: url,
      name: name,
    );
  }
}

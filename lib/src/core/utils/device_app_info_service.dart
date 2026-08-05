import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paywall_demo/src/feature/settings/model/app_device_info.dart';

// Сервис для получения информации о приложении
class DeviceAppInfoService {
  static final _deviceInfo = DeviceInfoPlugin();
  static PackageInfo? _packageInfo;

  // Основной метод получения всей информации
  static Future<AppDeviceInfo> fetchAppDeviceInfo() async {
    try {
      // Получаем информацию о пакете
      _packageInfo ??= await PackageInfo.fromPlatform();

      // Определяем платформу и получаем специфичные данные
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return _createAndroidInfo(androidInfo);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return _createIosInfo(iosInfo);
      }
      throw UnsupportedError('Unsupported platform');
    } on PlatformException catch (e) {
      throw Exception('Failed to get device info: ${e.message}');
    }
  }

  // Создание объекта для Android
  static AppDeviceInfo _createAndroidInfo(AndroidDeviceInfo info) {
    return AppDeviceInfo(
      platform: 'Android',
      deviceModel: info.model,
      osVersion: info.version.release,
      manufacturer: info.manufacturer,
      isPhysicalDevice: info.isPhysicalDevice,
      deviceId: info.id,
      appName: _packageInfo!.appName,
      packageName: _packageInfo!.packageName,
      appVersion: _packageInfo!.version,
      buildNumber: _packageInfo!.buildNumber,
    );
  }

  // Создание объекта для iOS
  static AppDeviceInfo _createIosInfo(IosDeviceInfo info) {
    return AppDeviceInfo(
      platform: 'iOS',
      deviceModel: info.modelName,
      osVersion: info.systemVersion,
      isPhysicalDevice: info.isPhysicalDevice,
      deviceId: info.identifierForVendor,
      appName: _packageInfo!.appName,
      packageName: _packageInfo!.packageName,
      appVersion: _packageInfo!.version,
      buildNumber: _packageInfo!.buildNumber,
    );
  }
}

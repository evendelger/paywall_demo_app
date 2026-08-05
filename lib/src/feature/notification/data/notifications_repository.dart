import 'package:client_api/client_api.dart';

abstract interface class INotificationsRepository {
  Future<void> registerPushToken({String? token});

  Future<void> deletePushToken();
}

final class NotificationsRepository implements INotificationsRepository {
  NotificationsRepository({
    required ClientApi client,
  });

  @override
  Future<void> registerPushToken({String? token}) async {
    // try {
    //   final deviceType = Platform.isAndroid
    //       ? DeviceType.android
    //       : Platform.isIOS
    //       ? DeviceType.ios
    //       : null;

    //   final pushToken = token ?? await FirebaseMessaging.instance.getToken();
    //   if (pushToken == null) return;

    //   final deviceAppInfo = await _getDeviceAppInfo();

    //   final request = RegisterPushTokenRequest(
    //     token: pushToken,
    //     deviceModel: deviceAppInfo.deviceModel,
    //     appVersion: deviceAppInfo.appVersion,
    //     deviceType: deviceType,
    //   );

    //   await _client.registerPushToken(request: request);
    // } on DioException catch (error) {
    //   mainTalker.error('Ошибка при регистрации push токена - $error');
    // }
  }

  @override
  Future<void> deletePushToken() async {
    // try {
    //   final pushToken = await FirebaseMessaging.instance.getToken();
    //   if (pushToken == null) return;

    //   final deviceAppInfo = await _getDeviceAppInfo();

    //   final request = DeletePushTokenRequest(
    //     token: pushToken,
    //     deviceModel: deviceAppInfo.deviceModel,
    //     appVersion: deviceAppInfo.appVersion,
    //     deviceType: _deviceType,
    //   );

    //   await _client.deletePushToken(request: request);
    // } on DioException catch (error) {
    //   mainTalker.error('Ошибка при удалении push токена - $error');
    // }
  }

  // DeviceType? get _deviceType => Platform.isAndroid
  //     ? DeviceType.android
  //     : Platform.isIOS
  //     ? DeviceType.ios
  //     : null;

  // Future<({String? deviceModel, String? appVersion})>
  // _getDeviceAppInfo() async {
  //   final deviceInfo = await DeviceAppInfoService.fetchAppDeviceInfo();
  //   final deviceModel = deviceInfo.deviceModel;
  //   final appVersion = deviceInfo.appVersion;
  //   return (deviceModel: deviceModel, appVersion: appVersion);
  // }
}

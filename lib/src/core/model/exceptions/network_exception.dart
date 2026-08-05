import 'package:paywall_demo/src/core/model/model.dart';

/// Ошибка отсутствия интернет-соединения
final class NetworkException implements AppException {
  const NetworkException();
}

/// Ошибка авторизации — вход выполнен с другого устройства
final class UnauthorizedException implements AppException {
  const UnauthorizedException();
}

import 'package:paywall_demo/src/core/model/model.dart';

/// Ошибка, которая может содержать сообщение с API
abstract interface class ApiException implements AppException {
  const ApiException([this.message]);

  final String? message;
}

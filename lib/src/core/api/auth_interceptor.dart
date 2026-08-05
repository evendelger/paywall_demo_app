import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:paywall_demo/src/feature/auth/data/repositories/token_storage.dart';

/// {@template auth_interceptor}
/// Интерсептор авторизации: подставляет Bearer-токен в запросы
/// и разлогинивает пользователя при ответе 401
/// {@endtemplate}
final class AuthInterceptor extends Interceptor {
  /// {@macro auth_interceptor}
  AuthInterceptor(
    this.dio, {
    required this.onLogout,
    required this.tokenStorage,
  });

  /// Колбэк выхода из аккаунта при 401
  final Future<void> Function() onLogout;

  /// Хранилище токена
  final ITokenStorage tokenStorage;

  /// Клиент Dio
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.token;
    log('Auth Token: $token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await onLogout();
      await tokenStorage.removeToken();

      return handler.next(err);
    } else {
      handler.next(err);
    }
  }
}

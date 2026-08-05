import 'package:dio/dio.dart';
import 'package:paywall_demo/src/core/model/model.dart';

extension DioX on DioException {
  static const _networkErrorTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  };

  Never throwCustom<T extends Exception>(
    StackTrace stackTrace, {
    required T unknownError,
    required T Function(String message) errorBuilder,
  }) {
    if (_networkErrorTypes.contains(type)) {
      return Error.throwWithStackTrace(
        const NetworkException(),
        stackTrace,
      );
    }

    final data = response?.data;
    if (data is! Map) {
      return Error.throwWithStackTrace(unknownError, stackTrace);
    }

    final map = Map<String, dynamic>.from(data);
    final message = map['message'] as String?;

    if (response?.statusCode == 401) {
      return Error.throwWithStackTrace(
        const UnauthorizedException(),
        stackTrace,
      );
    }

    if (message == null) {
      return Error.throwWithStackTrace(unknownError, stackTrace);
    }

    return Error.throwWithStackTrace(
      errorBuilder(message),
      stackTrace,
    );
  }
}

import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

abstract interface class IApiClient {
  Dio get dio;
}

final class ApiClient implements IApiClient {
  const ApiClient({
    required this._talker,
    required this._baseUrl,
  });

  final Talker _talker;

  final String _baseUrl;

  static Duration get _timeoutDurarion => const Duration(seconds: 15);

  @override
  Dio get dio => Dio()
    ..options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeoutDurarion,
      receiveTimeout: _timeoutDurarion,
      sendTimeout: _timeoutDurarion,
      headers: {
        'Accept': 'application/json',
      },
      contentType: Headers.jsonContentType,
    )
    ..interceptors.addAll(
      [
        TalkerDioLogger(
          talker: _talker,
          settings: const TalkerDioLoggerSettings(
            printErrorHeaders: false,
          ),
        ),
      ],
    );
}

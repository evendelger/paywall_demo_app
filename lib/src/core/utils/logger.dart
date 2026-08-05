import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Единственный инстанс [Talker] в приложении.
///
/// Обращаться к логгеру нужно только через него — своих инстансов
/// Talker/логгеров заводить не следует.
final Talker mainTalker = TalkerFlutter.init();

/// {@template app_logger}
/// Обработчики ошибок приложения.
///
/// Подключаются в `MainRunner`: [logFlutterError] — во `FlutterError.onError`,
/// [logZoneError] — в `runZonedGuarded`.
/// {@endtemplate}
abstract final class AppLogger {
  /// Логирование ошибок фреймворка Flutter
  static void logFlutterError(FlutterErrorDetails details) => mainTalker.handle(
    details.exception,
    details.stack,
    details.context?.toDescription(),
  );

  /// Логирование необработанных ошибок зоны
  static void logZoneError(Object error, StackTrace stackTrace) =>
      mainTalker.handle(error, stackTrace);
}

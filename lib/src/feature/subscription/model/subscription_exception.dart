import 'package:paywall_demo/src/core/model/model.dart';

/// Типы ошибок сценариев подписки
enum SubscriptionErrorType {
  /// Покупка не прошла
  purchaseFailed,

  /// Восстанавливать нечего — активной покупки нет
  nothingToRestore,

  /// Неизвестная ошибка
  unknown,
}

/// {@template subscription_exception}
/// Ошибка сценариев подписки.
///
/// Наследует `ApiException`, чтобы сообщение от реального биллинга можно
/// было прокинуть без правок UI, когда покупка перестанет быть эмуляцией.
/// {@endtemplate}
final class SubscriptionException implements ApiException {
  /// {@macro subscription_exception}
  const SubscriptionException([
    this.type = SubscriptionErrorType.unknown,
    this.message,
  ]);

  /// Тип ошибки
  final SubscriptionErrorType type;

  @override
  final String? message;
}

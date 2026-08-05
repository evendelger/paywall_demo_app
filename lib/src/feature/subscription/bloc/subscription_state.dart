part of 'subscription_bloc.dart';

@freezed
sealed class SubscriptionState with _$SubscriptionState {
  const SubscriptionState._();

  /// Ждём действия пользователя
  const factory SubscriptionState.idle({
    required SubscriptionStatus status,
    required SubscriptionPlan selectedPlan,
  }) = SubscriptionStateIdle;

  /// Идёт покупка или восстановление
  const factory SubscriptionState.processing({
    required SubscriptionStatus status,
    required SubscriptionPlan selectedPlan,
  }) = SubscriptionStateProcessing;

  /// Сценарий завершён успешно
  const factory SubscriptionState.successful({
    required SubscriptionStatus status,
    required SubscriptionPlan selectedPlan,
  }) = SubscriptionStateSuccessful;

  /// Сценарий завершён ошибкой
  const factory SubscriptionState.error({
    required SubscriptionStatus status,
    required SubscriptionPlan selectedPlan,
    AppException? exception,
  }) = SubscriptionStateError;

  /// Идёт ли сейчас покупка или восстановление
  bool get isProcessing => this is SubscriptionStateProcessing;

  /// Активна ли подписка
  bool get isActive => status.isActive;

  /// Ошибка последнего сценария, если он завершился неудачно
  AppException? get error => switch (this) {
    final SubscriptionStateError state => state.exception,
    _ => null,
  };
}

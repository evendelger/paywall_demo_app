part of 'subscription_bloc.dart';

@freezed
sealed class SubscriptionEvent with _$SubscriptionEvent {
  /// Выбрать тариф на пейволе
  const factory SubscriptionEvent.selectPlan({
    required SubscriptionPlan plan,
  }) = _SelectPlan;

  /// Купить выбранный тариф
  const factory SubscriptionEvent.purchase() = _Purchase;

  /// Восстановить ранее совершённую покупку
  const factory SubscriptionEvent.restore() = _Restore;

  /// Подменить статус подписки.
  ///
  /// Только для dev-инструментов: так проверяются состояния, до которых
  /// из обычного UI не добраться
  const factory SubscriptionEvent.applyStatus({
    required SubscriptionStatus status,
  }) = _ApplyStatus;

  /// Сбросить подписку — чтобы пройти флоу заново
  const factory SubscriptionEvent.reset() = _Reset;
}

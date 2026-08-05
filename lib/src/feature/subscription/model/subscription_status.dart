import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';

part 'subscription_status.freezed.dart';

/// {@template subscription_status}
/// Статус подписки пользователя: что куплено, когда и до какого момента.
///
/// Живёт в `SharedPreferences` и переживает перезапуск приложения —
/// на него смотрит `SubscriptionGuard` при выборе стартового экрана.
///
/// Активности как отдельного флага нет: она выводится из [expiresAt].
/// Хранить её вторым значением означало бы получить статус, который
/// «активен» после истечения срока.
/// {@endtemplate}
@freezed
abstract class SubscriptionStatus with _$SubscriptionStatus {
  /// {@macro subscription_status}
  const factory SubscriptionStatus({
    SubscriptionPlan? plan,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    @Default(false) bool isTrial,
  }) = _SubscriptionStatus;

  /// Статус после покупки [plan] в момент [at].
  ///
  /// Срок считает сам тариф, поэтому «купить в прошлом» — это способ
  /// получить истёкшую подписку, а не отдельная ветка логики
  factory SubscriptionStatus.purchased(SubscriptionPlan plan, {DateTime? at}) {
    final purchasedAt = at ?? DateTime.now();

    return SubscriptionStatus(
      plan: plan,
      purchasedAt: purchasedAt,
      expiresAt: plan.expirationFrom(purchasedAt),
      isTrial: plan.hasTrial,
    );
  }

  const SubscriptionStatus._();

  /// Подписки нет: состояние на чистой установке и после сброса
  static const SubscriptionStatus inactive = SubscriptionStatus();

  /// Действует ли подписка прямо сейчас
  bool get isActive {
    final expiresAt = this.expiresAt;

    return expiresAt != null && expiresAt.isAfter(DateTime.now());
  }
}

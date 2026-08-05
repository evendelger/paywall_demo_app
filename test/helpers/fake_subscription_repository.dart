import 'dart:async';

import 'package:paywall_demo/src/feature/subscription/data/repository/subscription_repository.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_exception.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';

/// Репозиторий подписки в памяти — без `SharedPreferences` и задержек
final class FakeSubscriptionRepository implements ISubscriptionRepository {
  FakeSubscriptionRepository({
    this._status = SubscriptionStatus.inactive,
  });

  SubscriptionStatus _status;

  /// Пока не завершён — покупка и восстановление «висят».
  ///
  /// Так тест держит состояние `processing` сколько нужно и при этом
  /// не оставляет после себя незавершённых таймеров
  Completer<void>? pending;

  /// Сколько раз запускалась покупка — на этом проверяется `droppable`
  int purchaseCount = 0;

  @override
  SubscriptionStatus get currentStatus => _status;

  @override
  Future<SubscriptionStatus> purchase(SubscriptionPlan plan) async {
    purchaseCount++;

    await _wait();

    final purchasedAt = DateTime.now();

    return _status = SubscriptionStatus(
      plan: plan,
      purchasedAt: purchasedAt,
      expiresAt: plan.expirationFrom(purchasedAt),
      isTrial: plan.hasTrial,
    );
  }

  @override
  Future<SubscriptionStatus> restore() async {
    await _wait();

    if (!_status.isActive) {
      throw const SubscriptionException(SubscriptionErrorType.nothingToRestore);
    }

    return _status;
  }

  @override
  Future<void> applyStatus(SubscriptionStatus status) async {
    _status = status;
  }

  @override
  Future<void> clear() async {
    _status = SubscriptionStatus.inactive;
  }

  Future<void> _wait() => pending?.future ?? Future<void>.value();
}

import 'package:paywall_demo/src/core/utils/logger.dart';
import 'package:paywall_demo/src/feature/subscription/database/subscription_dao.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_exception.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';

/// {@template subscription_repository}
/// Репозиторий подписки.
///
/// Покупка эмулируется: вместо стора — задержка и запись в локальное
/// хранилище. Интерфейс при этом повторяет форму настоящего биллинга
/// (`purchase` / `restore` / типизированные ошибки), поэтому подменить
/// реализацию можно без правок блока и UI.
/// {@endtemplate}
abstract interface class ISubscriptionRepository {
  /// Текущий статус подписки.
  ///
  /// Читается синхронно: значение нужно `SubscriptionGuard` в момент первой
  /// навигации, когда ждать асинхронную загрузку уже некогда.
  SubscriptionStatus get currentStatus;

  /// Купить подписку по тарифу
  Future<SubscriptionStatus> purchase(SubscriptionPlan plan);

  /// Восстановить ранее совершённую покупку.
  ///
  /// Бросает [SubscriptionException] с `nothingToRestore`, если покупки нет.
  Future<SubscriptionStatus> restore();

  /// Записать произвольный статус.
  ///
  /// Нужен dev-инструментам: из обычного UI не добраться до состояний
  /// вроде истёкшей подписки, а проверять их надо.
  Future<void> applyStatus(SubscriptionStatus status);

  /// Сбросить подписку — чтобы пройти флоу заново
  Future<void> clear();
}

/// {@macro subscription_repository}
final class SubscriptionRepository implements ISubscriptionRepository {
  /// {@macro subscription_repository}
  const SubscriptionRepository({
    required this._subscriptionDao,
    this._purchaseDelay = _defaultPurchaseDelay,
  });

  /// Сколько «думает» эмулированный стор
  static const Duration _defaultPurchaseDelay = Duration(milliseconds: 1200);

  final ISubscriptionDao _subscriptionDao;

  final Duration _purchaseDelay;

  @override
  SubscriptionStatus get currentStatus {
    final plan = SubscriptionPlan.fromName(_subscriptionDao.plan.value);
    final expiresAt = _subscriptionDao.expiresAt.value;

    // Тариф не распознан или срока нет — считаем, что подписки нет: лучше
    // показать пейвол, чем пустить в приложение с непонятным статусом
    if (plan == null || expiresAt == null) return SubscriptionStatus.inactive;

    final purchasedAt = _subscriptionDao.purchasedAt.value;

    return SubscriptionStatus(
      plan: plan,
      purchasedAt: purchasedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(purchasedAt),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt),
      isTrial: _subscriptionDao.isTrial.value ?? false,
    );
  }

  @override
  Future<SubscriptionStatus> purchase(SubscriptionPlan plan) async {
    // Здесь в боевом приложении был бы вызов стора
    await Future<void>.delayed(_purchaseDelay);

    final status = SubscriptionStatus.purchased(plan);

    try {
      await _write(status);
    } on Object catch (error, stackTrace) {
      // Текст ошибки хранилища пользователю не показываем — только в лог
      mainTalker.handle(error, stackTrace, 'Не удалось сохранить покупку');

      throw const SubscriptionException(SubscriptionErrorType.purchaseFailed);
    }

    return status;
  }

  @override
  Future<SubscriptionStatus> restore() async {
    await Future<void>.delayed(_purchaseDelay);

    final status = currentStatus;

    if (!status.isActive) {
      throw const SubscriptionException(SubscriptionErrorType.nothingToRestore);
    }

    return status;
  }

  @override
  Future<void> applyStatus(SubscriptionStatus status) =>
      status.plan == null ? clear() : _write(status);

  @override
  Future<void> clear() => Future.wait([
    _subscriptionDao.plan.remove(),
    _subscriptionDao.purchasedAt.remove(),
    _subscriptionDao.expiresAt.remove(),
    _subscriptionDao.isTrial.remove(),
  ]);

  /// Записывает статус покупки
  Future<void> _write(SubscriptionStatus status) async {
    await Future.wait([
      if (status.plan case final plan?)
        _subscriptionDao.plan.setValue(plan.name),
      if (status.purchasedAt case final purchasedAt?)
        _subscriptionDao.purchasedAt.setValue(
          purchasedAt.millisecondsSinceEpoch,
        ),
      _subscriptionDao.isTrial.setValue(status.isTrial),
    ]);

    // Срок действия пишется последним: пока его нет, статус считается
    // неактивным — половинчатая запись не пустит в приложение
    if (status.expiresAt case final expiresAt?) {
      await _subscriptionDao.expiresAt.setValue(
        expiresAt.millisecondsSinceEpoch,
      );
    }
  }
}

import 'package:paywall_demo/src/core/database/shared_preferences/typed_preferences_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template subscription_dao}
/// Хранилище статуса подписки в `SharedPreferences`.
///
/// Не Drift: значения скалярные, а читать их нужно синхронно — на них
/// смотрит `SubscriptionGuard` ещё до первого кадра.
/// {@endtemplate}
abstract class ISubscriptionDao {
  /// Имя купленного тарифа — `SubscriptionPlan.name`
  PreferencesEntry<String> get plan;

  /// Дата покупки в миллисекундах с начала эпохи
  PreferencesEntry<int> get purchasedAt;

  /// Дата окончания подписки в миллисекундах с начала эпохи.
  ///
  /// Именно она определяет, активна ли подписка — отдельного флага нет
  PreferencesEntry<int> get expiresAt;

  /// Куплено в рамках пробного периода
  PreferencesEntry<bool> get isTrial;
}

/// {@macro subscription_dao}
final class SubscriptionDao extends TypedPreferencesDao
    implements ISubscriptionDao {
  /// {@macro subscription_dao}
  SubscriptionDao({required SharedPreferences sharedPreferences})
    : super(sharedPreferences, name: 'subscription');

  @override
  PreferencesEntry<String> get plan => stringEntry('plan');

  @override
  PreferencesEntry<int> get purchasedAt => intEntry('purchased_at');

  @override
  PreferencesEntry<int> get expiresAt => intEntry('expires_at');

  @override
  PreferencesEntry<bool> get isTrial => boolEntry('is_trial');
}

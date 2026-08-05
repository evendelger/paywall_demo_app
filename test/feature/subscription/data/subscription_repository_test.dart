import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/feature/subscription/data/repository/subscription_repository.dart';
import 'package:paywall_demo/src/feature/subscription/database/subscription_dao.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_exception.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SubscriptionRepository', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('на чистой установке подписки нет', () async {
      final repository = await _createRepository();

      expect(repository.currentStatus.isActive, isFalse);
      expect(repository.currentStatus.plan, isNull);
    });

    test('покупка переживает перезапуск приложения', () async {
      await (await _createRepository()).purchase(SubscriptionPlan.yearly);

      // Новый репозиторий поверх того же хранилища — как после перезапуска
      final status = (await _createRepository()).currentStatus;

      expect(status.isActive, isTrue);
      expect(status.plan, SubscriptionPlan.yearly);
      expect(status.isTrial, isTrue);
      expect(status.purchasedAt, isNotNull);
      expect(status.expiresAt, isNotNull);
    });

    test('истёкшая подписка перестаёт быть активной сама', () async {
      final dao = await _createDao();

      await dao.plan.setValue(SubscriptionPlan.yearly.name);
      await dao.expiresAt.setValue(
        DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
      );

      final status = _createRepositoryOver(dao).currentStatus;

      // Данные читаются, но судит об активности срок, а не отдельный флаг
      expect(status.plan, SubscriptionPlan.yearly);
      expect(status.isActive, isFalse);
    });

    test('восстанавливать нечего, пока покупки не было', () async {
      final repository = await _createRepository();

      expect(
        repository.restore,
        throwsA(
          isA<SubscriptionException>().having(
            (error) => error.type,
            'type',
            SubscriptionErrorType.nothingToRestore,
          ),
        ),
      );
    });

    test('восстановление возвращает ранее купленный тариф', () async {
      final repository = await _createRepository();

      await repository.purchase(SubscriptionPlan.monthly);
      final status = await repository.restore();

      expect(status.isActive, isTrue);
      expect(status.plan, SubscriptionPlan.monthly);
      expect(status.isTrial, isFalse);
    });

    test('сброс возвращает состояние к отсутствию подписки', () async {
      final repository = await _createRepository();

      await repository.purchase(SubscriptionPlan.yearly);
      await repository.clear();

      expect(repository.currentStatus.isActive, isFalse);
      expect((await _createRepository()).currentStatus.isActive, isFalse);
    });
  });
}

Future<ISubscriptionDao> _createDao() async =>
    SubscriptionDao(sharedPreferences: await SharedPreferences.getInstance());

/// Задержку эмуляции в тестах убираем — она про UX, а не про хранение
ISubscriptionRepository _createRepositoryOver(ISubscriptionDao dao) =>
    SubscriptionRepository(subscriptionDao: dao, purchaseDelay: Duration.zero);

Future<ISubscriptionRepository> _createRepository() async =>
    _createRepositoryOver(await _createDao());

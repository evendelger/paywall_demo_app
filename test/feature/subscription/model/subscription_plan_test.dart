import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';

void main() {
  const monthly = SubscriptionPlan.monthly;
  const yearly = SubscriptionPlan.yearly;

  group('SubscriptionPlan', () {
    test('цена в пересчёте на месяц делится на длительность периода', () {
      expect(monthly.pricePerMonth, monthly.price);
      expect(yearly.pricePerMonth, yearly.price / yearly.months);
    });

    test('выгода считается из цен обоих тарифов', () {
      // 2 990 / 12 ≈ 249 ₽ против 399 ₽ — примерно 38 %.
      // Цифра завязана на текущие цены: поменяли цену — поменяйте и здесь
      expect(yearly.pricePerMonth, lessThan(monthly.pricePerMonth));
      expect(yearly.savingsPercent, 38);
      expect(yearly.hasSavings, isTrue);
    });

    test('базовый тариф сам с собой не сравнивается', () {
      expect(monthly.savingsPercent, 0);
      expect(monthly.hasSavings, isFalse);
    });

    test('пробный период есть только у годового тарифа', () {
      expect(yearly.hasTrial, isTrue);
      expect(monthly.hasTrial, isFalse);
    });

    test('срок действия — пробный период плюс оплаченный', () {
      final from = DateTime(2026, 8, 6, 12, 30);

      expect(
        monthly.expirationFrom(from),
        DateTime(2026, 9, 6, 12, 30),
      );
      // 7 дней триала, следом год
      expect(
        yearly.expirationFrom(from),
        DateTime(2027, 8, 13, 12, 30),
      );
    });

    test('неизвестное имя тарифа из хранилища не роняет приложение', () {
      expect(SubscriptionPlan.fromName('yearly'), yearly);
      expect(SubscriptionPlan.fromName('weekly'), isNull);
      expect(SubscriptionPlan.fromName(null), isNull);
    });
  });
}

import 'dart:math' show max;

/// {@template subscription_plan}
/// Тариф подписки.
///
/// Всё, что пейвол показывает про тариф, выводится из этих трёх полей:
/// цена в пересчёте на месяц, процент экономии, длительность триала.
/// Поэтому смена цены двигает весь экран — руками в UI править нечего.
/// {@endtemplate}
enum SubscriptionPlan {
  /// Помесячный тариф — базовый, с ним сравнивается выгода остальных
  monthly(price: 399, months: 1, trialDays: 0),

  /// Годовой тариф — дешевле в пересчёте на месяц, с пробным периодом
  yearly(price: 2990, months: 12, trialDays: 7);

  /// {@macro subscription_plan}
  const SubscriptionPlan({
    required this.price,
    required this.months,
    required this.trialDays,
  });

  /// Стоимость всего периода
  final double price;

  /// Длительность периода в месяцах
  final int months;

  /// Длительность пробного периода в днях, `0` — триала нет
  final int trialDays;

  /// Есть ли у тарифа пробный период
  bool get hasTrial => trialDays > 0;

  /// Стоимость в пересчёте на месяц
  double get pricePerMonth => price / months;

  /// Нужно ли показывать цену за месяц отдельной строкой
  bool get hasPricePerMonth => months > 1;

  /// Выгода относительно самого дорогого месяца, в процентах.
  ///
  /// Считается из цен, а не хранится вторым числом: иначе цена и «экономия»
  /// разъедутся при первой же правке тарифа.
  int get savingsPercent {
    final base = _basePricePerMonth;

    if (base <= 0 || pricePerMonth >= base) return 0;

    return ((1 - pricePerMonth / base) * 100).round();
  }

  /// Есть ли выгода по сравнению с базовым тарифом
  bool get hasSavings => savingsPercent > 0;

  /// До какого момента действует подписка, купленная в момент [from].
  ///
  /// Сначала идёт пробный период, следом — оплаченный: пользователь,
  /// не отменивший подписку, платит на восьмой день и получает год сверху.
  DateTime expirationFrom(DateTime from) {
    final trialEnd = from.add(Duration(days: trialDays));

    return DateTime(
      trialEnd.year,
      trialEnd.month + months,
      trialEnd.day,
      trialEnd.hour,
      trialEnd.minute,
      trialEnd.second,
    );
  }

  /// Самая дорогая цена месяца среди тарифов — база для расчёта экономии
  static double get _basePricePerMonth =>
      values.map((plan) => plan.pricePerMonth).reduce(max);

  /// Тариф по имени из хранилища.
  ///
  /// `null`, если значения нет или оно осталось от старой версии приложения —
  /// такой статус считаем неактивным, а не падаем.
  static SubscriptionPlan? fromName(String? name) {
    for (final plan in values) {
      if (plan.name == name) return plan;
    }

    return null;
  }
}

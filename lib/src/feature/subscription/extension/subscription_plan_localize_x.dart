import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/utils/utils.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';

/// Тексты тарифа для UI.
///
/// Все цифры приходят из самого [SubscriptionPlan] — экран ничего
/// не пересчитывает и ничего не хардкодит.
extension SubscriptionPlanLocalizedX on SubscriptionPlan {
  /// Название тарифа
  String title(BuildContext context) => switch (this) {
    SubscriptionPlan.monthly => context.l10n.planMonthlyLabel,
    SubscriptionPlan.yearly => context.l10n.planYearlyLabel,
  };

  /// Цена за весь период тарифа
  String priceLabel(BuildContext context) {
    final formatted = PriceFormatter.format(price);

    return switch (this) {
      SubscriptionPlan.monthly => context.l10n.planPricePerMonth(formatted),
      SubscriptionPlan.yearly => context.l10n.planPricePerYear(formatted),
    };
  }

  /// Цена в пересчёте на месяц — только у тарифов длиннее месяца
  String? pricePerMonthLabel(BuildContext context) => hasPricePerMonth
      ? context.l10n.planPricePerMonth(PriceFormatter.format(pricePerMonth))
      : null;

  /// Бейдж выгоды, если тариф выгоднее базового
  String? savingsLabel(BuildContext context) =>
      hasSavings ? context.l10n.planSavingsBadge(savingsPercent) : null;

  /// Бейдж пробного периода, если он есть
  String? trialLabel(BuildContext context) =>
      hasTrial ? context.l10n.planTrialBadge(trialDays) : null;

  /// Сноска под кнопкой: что и когда спишется
  String disclaimer(BuildContext context) {
    final formatted = PriceFormatter.format(price);

    return hasTrial
        ? context.l10n.paywallTrialDisclaimer(trialDays, formatted)
        : context.l10n.paywallDisclaimer(formatted);
  }
}

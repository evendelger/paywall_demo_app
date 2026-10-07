import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/app/widget/dev_tools_button.dart';
import 'package:paywall_demo/src/feature/subscription/extension/subscription_plan_localize_x.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/scope/subscription_scope.dart';
import 'package:paywall_demo/src/feature/subscription/widget/paywall_benefits.dart';
import 'package:paywall_demo/src/feature/subscription/widget/paywall_legal_links.dart';
import 'package:paywall_demo/src/feature/subscription/widget/subscription_listener.dart';
import 'package:paywall_demo/src/feature/subscription/widget/subscription_plan_card.dart';

/// {@template paywall_screen}
/// Пейвол: выбор тарифа и покупка подписки.
///
/// Экран не решает, куда вести пользователя дальше: он запускает покупку,
/// а после сохранения статуса `SubscriptionListener` просит роутер
/// перепроверить гарды — маршрут выбирает цепочка гардов на ветке `/`.
/// {@endtemplate}
@RoutePage()
class PaywallScreen extends StatelessWidget {
  /// {@macro paywall_screen}
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return SubscriptionListener(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: DevToolsButton(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    UIConfig.kSidePadding,
                    UIConfig.kSidePadding,
                    UIConfig.kSidePadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.paywallTitle,
                        style: textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.paywallSubtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Center(child: _DemoNotice()),
                      const SizedBox(height: 24),
                      const PaywallBenefits(),
                      const SizedBox(height: 24),
                      const _PlanList(),
                    ],
                  ),
                ),
              ),
              const _PaywallFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Плашка о том, что покупка ненастоящая — честнее сказать это на экране,
/// чем только в README
class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UIConfig.kBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          context.l10n.paywallDemoNotice,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Карточки тарифов
class _PlanList extends StatelessWidget {
  const _PlanList();

  @override
  Widget build(BuildContext context) {
    final selectedPlan = SubscriptionScope.selectedPlanOf(
      context,
      listen: true,
    );

    // Порядок в enum задаёт порядок на экране: сначала помесячный,
    // следом годовой — выбранный по умолчанию
    return Column(
      children: [
        for (final plan in SubscriptionPlan.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SubscriptionPlanCard(
              plan: plan,
              isSelected: plan == selectedPlan,
              onTap: () => SubscriptionScope.selectPlan(context, plan),
            ),
          ),
      ],
    );
  }
}

/// Кнопка покупки, восстановление покупок и легальные ссылки
class _PaywallFooter extends StatelessWidget {
  const _PaywallFooter();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final plan = SubscriptionScope.selectedPlanOf(context, listen: true);
    final isProcessing = SubscriptionScope.isProcessingOf(
      context,
      listen: true,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UIConfig.kSidePadding,
        UIConfig.kListPadding,
        UIConfig.kSidePadding,
        UIConfig.kSidePadding,
      ),
      child: Column(
        children: [
          Text(
            plan.disclaimer(context),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              // Пробный период меняет обещание кнопки: бесплатно или платно
              title: plan.hasTrial ? l10n.actionStartFree : l10n.actionContinue,
              isLoading: isProcessing,
              onPressed: () => SubscriptionScope.purchase(context),
            ),
          ),
          TextButton(
            onPressed: isProcessing
                ? null
                : () => SubscriptionScope.restore(context),
            child: Text(l10n.actionRestorePurchases),
          ),
          const PaywallLegalLinks(),
        ],
      ),
    );
  }
}

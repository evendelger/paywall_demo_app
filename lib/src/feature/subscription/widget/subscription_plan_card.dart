import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/subscription/extension/subscription_plan_localize_x.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';

/// {@template subscription_plan_card}
/// Карточка тарифа на пейволе.
///
/// Цена периода, цена в пересчёте на месяц, выгода и пробный период
/// приходят из самого [SubscriptionPlan] — в карточке нет ни одного
/// числа, которое не считалось бы из цен тарифов.
/// {@endtemplate}
class SubscriptionPlanCard extends StatelessWidget {
  /// {@macro subscription_plan_card}
  const SubscriptionPlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Тариф, который показывает карточка
  final SubscriptionPlan plan;

  /// Выбран ли тариф сейчас
  final bool isSelected;

  /// Нажатие по карточке
  final VoidCallback onTap;

  /// Размер индикатора выбора
  static const double _markerSize = 24;

  /// Толщина рамки выбранной карточки
  static const double _selectedBorderWidth = 2;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final pricePerMonth = plan.pricePerMonthLabel(context);
    final savings = plan.savingsLabel(context);
    final trial = plan.trialLabel(context);

    return AppCard(
      onTap: onTap,
      color: isSelected
          ? colorScheme.primary.withValues(alpha: 0.06)
          : colorScheme.surface,
      borderSide: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        width: isSelected ? _selectedBorderWidth : 1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConfig.kListPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SelectionMarker(isSelected: isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.title(context),
                          style: textTheme.titleMedium,
                        ),
                      ),
                      if (savings != null)
                        _PlanBadge(
                          label: savings,
                          background: colorScheme.primary,
                          foreground: colorScheme.onPrimary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.priceLabel(context),
                    style: textTheme.titleLarge,
                  ),
                  if (pricePerMonth != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      pricePerMonth,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (trial != null) ...[
                    const SizedBox(height: 8),
                    _PlanBadge(
                      label: trial,
                      background: colorScheme.surfaceContainerHighest,
                      foreground: colorScheme.onSurface,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Кружок слева: отмечает выбранный тариф
class _SelectionMarker extends StatelessWidget {
  const _SelectionMarker({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SizedBox.square(
      dimension: SubscriptionPlanCard._markerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? colorScheme.primary : null,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: SubscriptionPlanCard._selectedBorderWidth,
          ),
        ),
        child: isSelected
            ? Padding(
                padding: const EdgeInsets.all(5),
                child: Assets.icons.check.svg(
                  colorFilter: ColorFilter.mode(
                    colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Бейдж на карточке: выгода или пробный период
class _PlanBadge extends StatelessWidget {
  const _PlanBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;

  final Color background;

  final Color foreground;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(UIConfig.kBorderRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(color: foreground),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template paywall_benefits}
/// Список того, что даёт подписка.
/// {@endtemplate}
class PaywallBenefits extends StatelessWidget {
  /// {@macro paywall_benefits}
  const PaywallBenefits({super.key});

  /// Размер иконки в строке
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final benefits = [
      l10n.paywallBenefit1,
      l10n.paywallBenefit2,
      l10n.paywallBenefit3,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final benefit in benefits)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Assets.icons.check.svg(
                  width: _iconSize,
                  height: _iconSize,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(benefit, style: context.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/utils/utils.dart';

/// {@template paywall_legal_links}
/// Ссылки на условия использования и политику конфиденциальности.
///
/// Адреса приходят из `Config` (`TERMS_URL` / `PRIVACY_URL`) — в виджете
/// их нет, у разных флейворов они могут отличаться.
/// {@endtemplate}
class PaywallLegalLinks extends StatelessWidget {
  /// {@macro paywall_legal_links}
  const PaywallLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: UIConfig.kListPadding,
      children: [
        _LegalLink(label: l10n.termsLabel, url: Config.termsUrl),
        _LegalLink(label: l10n.privacyLabel, url: Config.privacyUrl),
      ],
    );
  }
}

/// Одна ссылка: открывается во внешнем браузере
class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.url});

  final String label;

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: () => unawaited(UrlLauncher.openUrl(url)),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          decoration: TextDecoration.underline,
          decorationColor: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_exception.dart';

extension SubscriptionExceptionLocalizedX on SubscriptionException {
  String localizedSubscription(BuildContext context) {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    final l10n = context.l10n;

    switch (type) {
      case SubscriptionErrorType.purchaseFailed:
        return l10n.errorPurchaseFailed;
      case SubscriptionErrorType.nothingToRestore:
        return l10n.errorNothingToRestore;
      case SubscriptionErrorType.unknown:
        return l10n.errorUnknown;
    }
  }
}

import 'package:flutter/widgets.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/model/model.dart';
import 'package:paywall_demo/src/feature/auth/extension/auth_exception_localize_x.dart';
import 'package:paywall_demo/src/feature/auth/model/exceptions/auth_exception.dart';
import 'package:paywall_demo/src/feature/user/extension/user_exception_localize_x.dart';
import 'package:paywall_demo/src/feature/user/model/user_exception.dart';

extension AppExceptionLocalizedX on AppException {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      final AuthException e => e.localizedAuth(context),
      final UserException e => e.localizedUser(context),
      final ApiException e => e.message ?? l10n.errorUnknown,
      _ => l10n.errorUnknown,
    };
  }
}

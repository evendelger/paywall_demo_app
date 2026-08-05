import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/feature/auth/model/exceptions/auth_exception.dart';

extension AuthExceptionLocalizeX on AuthException {
  String localizedAuth(BuildContext context) {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    final l10 = context.l10n;

    switch (type) {
      case AuthErrorType.unknown:
        return l10.errorUnknown;
      case AuthErrorType.signOut:
        return l10.errorAuthSignOut;
      case AuthErrorType.sendCode:
        return l10.errorAuthSendCode;
      case AuthErrorType.verifyCode:
        return l10.errorAuthVerifyCode;
    }
  }
}

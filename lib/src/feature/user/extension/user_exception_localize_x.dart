import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/feature/user/model/user_exception.dart';

extension UserExceptionLocalizedX on UserException {
  String localizedUser(BuildContext context) {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    final l10 = context.l10n;

    switch (type) {
      case UserErrorType.unknown:
        return l10.errorUnknown;
      case UserErrorType.updateData:
        return l10.errorUserUpdate;
      case UserErrorType.getData:
        return l10.errorUserGet;
    }
  }
}

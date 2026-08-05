import 'package:flutter/material.dart';
import 'package:paywall_demo/src/feature/auth/scope/auth_scope.dart';
import 'package:paywall_demo/src/feature/onboarding/scope/onboarding_scope.dart';
import 'package:paywall_demo/src/feature/settings/scope/settings_scope.dart';
import 'package:paywall_demo/src/feature/subscription/scope/subscription_scope.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';

/// {@template app_scope}
/// Scope для всего приложения
/// {@endtemplate}
class AppScope extends StatelessWidget {
  /// {@macro app_scope}
  const AppScope({
    required this.initialUser,
    required this.child,
    super.key,
  });

  final User? initialUser;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Онбординг и подписка — выше роутера: их состояния читают гарды
    // ветки `/` ещё до построения первого экрана
    return SettingsScope(
      child: OnboardingScope(
        child: SubscriptionScope(
          child: AuthScope(initialUser: initialUser, child: child),
        ),
      ),
    );
  }
}

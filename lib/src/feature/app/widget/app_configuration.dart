import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/core/theme/theme.dart';
import 'package:paywall_demo/src/feature/onboarding/router/onboarding_guard.dart';
import 'package:paywall_demo/src/feature/onboarding/scope/onboarding_scope.dart';
import 'package:paywall_demo/src/feature/subscription/router/subscription_guard.dart';
import 'package:paywall_demo/src/feature/subscription/scope/subscription_scope.dart';

class AppConfiguration extends StatefulWidget {
  const AppConfiguration({super.key});

  @override
  State<AppConfiguration> createState() => _AppConfigurationState();
}

class _AppConfigurationState extends State<AppConfiguration> {
  /// Гарды ветки `/`, в порядке проверки.
  ///
  /// Создаются один раз: состояния, на которые они смотрят, живут выше
  /// по дереву (см. `AppScope`) и не пересоздаются.
  late final List<AutoRouteGuard> _rootGuards = [
    OnboardingGuard(OnboardingScope.cubitOf(context)),
    SubscriptionGuard(SubscriptionScope.blocOf(context)),
  ];

  @override
  Widget build(BuildContext context) {
    return AppRouterBuilder(
      rootGuards: _rootGuards,
      builder: (context, config) => MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme,
        onGenerateTitle: (context) => context.l10n.appName,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: config,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          final systemScale = MediaQuery.textScalerOf(context).scale(1);
          const maxAllowed = 1.15;
          final smoothScale = lerpDouble(
            1.0,
            maxAllowed,
            (systemScale - 1.0).clamp(0, 1),
          )!;

          final mediaQuery = MediaQuery(
            key: const ValueKey('prevent_rebuild'),
            data: data.copyWith(
              textScaler: data.textScaler.clamp(
                minScaleFactor: 1,
                maxScaleFactor: smoothScale,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );

          return mediaQuery;
        },
      ),
    );
  }
}

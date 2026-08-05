import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/core/theme/theme.dart';

class AppConfiguration extends StatelessWidget {
  const AppConfiguration({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRouterBuilder(
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

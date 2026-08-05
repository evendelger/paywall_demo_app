import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template home_screen}
/// Домашний экран
/// {@endtemplate}
@RoutePage()
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeLabel)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(UIConfig.kSidePadding),
          child: Text(
            l10n.appName,
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

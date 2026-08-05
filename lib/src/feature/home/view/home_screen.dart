import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/feature/app/widget/dev_tools_button.dart';

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
      appBar: AppBar(
        title: Text(l10n.homeLabel),
        actions: const [DevToolsButton()],
      ),
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

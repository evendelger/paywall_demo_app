import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template login_screen}
/// Экран авторизации — заготовка.
///
/// Авторизация в шаблоне необязательна: экран доступен по прямому переходу,
/// но приложение стартует на главном экране. Здесь добавляется форма входа,
/// которая дёргает `IAuthRepository`.
/// {@endtemplate}
@RoutePage()
class LoginScreen extends StatelessWidget {
  /// {@macro login_screen}
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authorizationLabel)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(UIConfig.kSidePadding),
          child: Text('TODO: форма входа'),
        ),
      ),
    );
  }
}

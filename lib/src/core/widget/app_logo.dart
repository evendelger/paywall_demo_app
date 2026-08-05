import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';

/// {@template logo}
/// Лого приложкеия
/// {@endtemplate}
class AppLogo extends StatelessWidget {
  /// {@macro logo}
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Assets.icons.logo.svg();
  }
}

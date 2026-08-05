import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/feature/app/widget/dev_tools_sheet.dart';

/// {@template dev_tools_button}
/// Точка входа в панель отладки [DevToolsSheet].
///
/// В production-сборке не рисуется вовсе — экраны, где она стоит, можно
/// не обкладывать проверками флейвора.
/// {@endtemplate}
class DevToolsButton extends StatelessWidget {
  /// {@macro dev_tools_button}
  const DevToolsButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Config.environment.isDevelopment) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Отладка',
      onPressed: () => unawaited(DevToolsSheet.show(context)),
      icon: const Icon(Icons.bug_report_outlined),
    );
  }
}

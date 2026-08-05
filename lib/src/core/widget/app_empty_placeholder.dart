import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template empty_placeholder}
/// Заглушка для пустых скринов
/// {@endtemplate}
class EmptyPlaceholder extends StatelessWidget {
  /// {@macro empty_placeholder}
  const EmptyPlaceholder({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(context.l10n.emptyText),
  );
}

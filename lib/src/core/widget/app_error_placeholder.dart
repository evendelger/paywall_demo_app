import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

class AppErrorPlaceholder extends StatelessWidget {
  const AppErrorPlaceholder({
    required this.onRetry,
    this.title,
    this.message,
    this.isCompact = false, // Флаг для управления размером
    super.key,
  });

  final VoidCallback onRetry;

  final String? title;

  final String? message;

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    // Адаптивные размеры
    final iconSize = isCompact ? 40.0 : 64.0;
    final iconPadding = isCompact ? 16.0 : 24.0;
    final spacing = isCompact ? 16.0 : 32.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка в круге
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: iconSize,
                color: colorScheme.error,
              ),
            ),
            SizedBox(height: spacing),

            // Заголовок
            Text(
              title ?? context.l10n.error,
              style: textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isCompact ? 8 : 12),

            // Основное сообщение
            Text(
              message ?? 'Проверьте интернет и попробуйте снова.',
              style: (isCompact ? textTheme.bodyMedium : textTheme.bodyLarge)
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isCompact ? 24 : 40),

            // Кнопка (в компактном режиме делаем её по размеру контента)
            SizedBox(
              width: isCompact ? null : double.infinity,
              child: AppButton(
                onPressed: onRetry,
                title: context.l10n.actionRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

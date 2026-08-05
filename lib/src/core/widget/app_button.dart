import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/theme/theme.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

enum AppButtonVariant { primary, secondary }

enum AppButtonSize { large, small }

/// {@template app_button}
/// AppButton widget
/// {@endtemplate}
class AppButton extends StatelessWidget {
  /// {@macro app_button}
  const AppButton({
    required this.title,
    this.variant = AppButtonVariant.primary,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = AppButtonSize.large,
    super.key,
  });

  final String title;

  final VoidCallback? onPressed;

  final bool isLoading;

  final Widget? icon;

  final AppButtonVariant variant;

  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final backgroundColor = switch (variant) {
      AppButtonVariant.primary => colorScheme.primary,
      AppButtonVariant.secondary => colorScheme.secondary,
    };
    final disabledBackgroundColor = backgroundColor.withValues(alpha: 0.15);

    final padding = switch (size) {
      AppButtonSize.large => const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      AppButtonSize.small => const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
    };

    final textStyle = switch (size) {
      AppButtonSize.large => textTheme.labelLarge,
      AppButtonSize.small => textTheme.labelMedium,
    }?.copyWith();

    return FilledButton(
      onPressed: onPressed != null
          ? () {
              if (!isLoading) {
                onPressed?.call();
              }
            }
          : null,

      style: context.theme.filledButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(textStyle),
        padding: WidgetStatePropertyAll(padding),
        backgroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.disabled)) {
            return disabledBackgroundColor;
          }
          return backgroundColor;
        }),
      ),
      child: AnimatedSwitcher(
        duration: AppAnimations.appButtonTransition,
        switchInCurve: AppAnimations.appButtonInCurve,
        switchOutCurve: AppAnimations.appButtonOutCurve,
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: isLoading
            ? AppLoader(color: colorScheme.onPrimary)
            : Text(
                title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}

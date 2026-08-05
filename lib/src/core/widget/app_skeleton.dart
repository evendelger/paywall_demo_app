import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:shimmer/shimmer.dart';

/// {@template skeleton}
/// Заглушка для загрузки
/// {@endtemplate}
class AppSkeleton extends StatelessWidget {
  /// {@macro skeleton}
  const AppSkeleton({
    required this.width,
    super.key,
    this.height = 16,
    this.borderRadius,
  });

  final double width;

  final double height;

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 800),
      baseColor: context.theme.colorScheme.secondary.withValues(alpha: .03),
      highlightColor: context.theme.colorScheme.secondary.withValues(alpha: .1),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// {@template widget_shimmer}
/// Шиммер поверх виджета
/// {@endtemplate}
class WidgetShimmer extends StatelessWidget {
  /// {@macro widget_shimmer}
  const WidgetShimmer({
    required this.child,
    required this.isLoading,
    super.key,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;

  final bool isLoading;

  final Color? baseColor;

  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return isLoading
        ? Shimmer.fromColors(
            period: const Duration(milliseconds: 750),
            baseColor: baseColor ?? colorScheme.surfaceContainer,
            highlightColor: highlightColor ?? colorScheme.surfaceContainerHigh,
            enabled: isLoading,
            child: child,
          )
        : child;
  }
}

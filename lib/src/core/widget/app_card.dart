import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template app_card}
/// AppCard widget
/// {@endtemplate}
class AppCard extends StatelessWidget {
  /// {@macro app_card}
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.radius = 16,
    this.color,
    this.highlightColor,
    this.borderSide,
  });

  final Widget child;

  final VoidCallback? onTap;

  final double radius;

  final Color? color;

  final Color? highlightColor;

  final BorderSide? borderSide;

  BorderRadius get radiusBorder => BorderRadius.circular(radius);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? context.theme.cardColor,
      borderRadius: radiusBorder,
      border: borderSide != null ? Border.fromBorderSide(borderSide!) : null,
    ),
    child: Material(
      borderRadius: radiusBorder,
      color: Colors.transparent,
      child: InkWell(
        highlightColor: highlightColor,
        borderRadius: radiusBorder,
        onTap: onTap != null
            ? () async {
                await HapticFeedback.lightImpact();
                onTap?.call();
              }
            : null,
        splashFactory: NoSplash.splashFactory,
        child: child,
      ),
    ),
  );
}

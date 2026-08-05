import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template circle_icon_button}
/// Закругленная кнопка с иконкой
/// {@endtemplate}
class AppRoundedIconButton extends StatelessWidget {
  /// {@macro circle_icon_button}
  const AppRoundedIconButton({
    this.icon,
    this.child,
    this.onPressed,
    this.dimension = 40,
    this.raduis = 4,
    this.showBorder = true,
    this.isDestructive = false,
    super.key,
  });

  final VoidCallback? onPressed;

  final SvgGenImage? icon;

  final Widget? child;

  final double dimension;

  final double raduis;

  final bool showBorder;

  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final br = BorderRadius.circular(raduis);
    final borderColor = isDestructive ? colorScheme.error : colorScheme.outline;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: br,
          child: Ink(
            height: dimension,
            width: dimension,
            decoration: BoxDecoration(
              borderRadius: br,
              border: showBorder ? Border.all(color: borderColor) : null,
            ),
            child: icon?.svg(fit: BoxFit.none) ?? child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/gen/assets.gen.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool enabled;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final border = !enabled
        ? Border.all(color: colorScheme.outline, width: 1.5)
        : null;
    final color = enabled ? colorScheme.primary : null;
    const double size = 22;

    return InkWell(
      onTap: () => onChanged(!enabled),
      borderRadius: BorderRadius.circular(100),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: border,
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: enabled ? Assets.icons.check.svg(fit: BoxFit.none) : null,
        ),
      ),
    );
  }
}

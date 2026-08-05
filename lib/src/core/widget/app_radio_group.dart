import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.selected,
    required this.onChanged,
    required this.items,
    required this.labelBuilder,
    super.key,
  });

  final T selected;

  final ValueChanged<T> onChanged;

  final List<T> items;

  final String Function(T item) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: items.map((item) {
        return GestureDetector(
          onTap: () => onChanged(item),
          behavior: HitTestBehavior.opaque,
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppRadioButton(
                value: item,
                enabled: item == selected,
                onChanged: (value) => onChanged(item),
              ),
              Text(
                labelBuilder(item),
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class AppRadioButton<T> extends StatelessWidget {
  const AppRadioButton({
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final T value;

  final bool enabled;

  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    const double size = 22;

    final border = !enabled
        ? Border.all(color: colorScheme.outline, width: 1.5)
        : null;
    final color = enabled ? colorScheme.primary : null;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(100),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: border,
            color: color,
          ),
          child: enabled ? Assets.icons.check.svg(fit: BoxFit.none) : null,
        ),
      ),
    );
  }
}

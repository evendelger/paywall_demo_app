import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

class AppActionList<T> extends StatelessWidget {
  const AppActionList({
    required this.items,
    required this.itemBuilder,
    required this.onPressed,
    this.verticalPadding = 16,
    this.horizontalPadding,
    this.itemSpacing = 40,
    super.key,
  });

  final List<T> items;

  final Widget Function(BuildContext context, T item) itemBuilder;

  final void Function(BuildContext context, T item) onPressed;

  final double verticalPadding;

  final double? horizontalPadding;

  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: items
          .mapIndexed((index, item) {
            final isFirst = index == 0;
            final isLast = index == items.length - 1;
            final spacing = itemSpacing / 2;

            return CupertinoButton(
              onPressed: () => onPressed(context, item),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              child: Padding(
                padding: EdgeInsets.only(
                  top: isFirst ? verticalPadding : spacing,
                  bottom: isLast ? verticalPadding : spacing,
                  left: horizontalPadding ?? 0,
                  right: horizontalPadding ?? 0,
                ),
                child: itemBuilder(context, item),
              ),
            );
          })
          .getSeparatedList(
            separator: const Divider(thickness: 1, height: 1),
          ),
    );
  }
}

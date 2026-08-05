import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/app_checkbox.dart';

class AppMultiDropdownButton<T> extends StatefulWidget {
  const AppMultiDropdownButton({
    required this.customButton,
    required this.items,
    required this.labelBuilder,
    this.selected,
    this.onChanged,
    this.width = 200,
    super.key,
  });

  final Widget customButton;

  final List<T> items;

  final List<T>? selected;

  final void Function(List<T>? values)? onChanged;

  final String Function(T item) labelBuilder;

  final double? width;

  @override
  State<AppMultiDropdownButton<T>> createState() =>
      _AppMultiDropdownButtonState<T>();
}

class _AppMultiDropdownButtonState<T> extends State<AppMultiDropdownButton<T>> {
  late final ValueNotifier<List<T>> _valuesNotifier = ValueNotifier(
    widget.selected ?? [],
  );

  @override
  void dispose() {
    _valuesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final br = BorderRadius.circular(4);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        customButton: widget.customButton,
        multiValueListenable: _valuesNotifier,
        items: _buildButtonItems(context, widget.items),
        onChanged: (value) {
          if (value == null) return;
          final current = List<T>.from(_valuesNotifier.value);
          if (current.contains(value)) {
            current.remove(value);
          } else {
            current.add(value);
          }
          _valuesNotifier.value = current;
          widget.onChanged?.call(_valuesNotifier.value);
        },
        dropdownSeparator: DropdownSeparator<T>(
          height: 1,
          child: const SizedBox.shrink(),
        ),
        menuItemStyleData: const MenuItemStyleData(
          padding: EdgeInsets.zero,
        ),
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.zero,
          width: double.infinity,
          elevation: 0,
        ),
        iconStyleData: const IconStyleData(
          icon: SizedBox.shrink(),
          iconSize: 0,
        ),
        isExpanded: true,
        style: textTheme.bodyLarge,
        dropdownStyleData: DropdownStyleData(
          useRootNavigator: true,
          padding: EdgeInsets.zero,
          width: widget.width,
          maxHeight: context.screenSize.height / 2.5,
          offset: const Offset(-16, -4),
          elevation: 2,
          decoration: BoxDecoration(
            borderRadius: br,
            color: colorScheme.surface,
          ),
        ),
      ),
    );
  }

  List<DropdownItem<T>> _buildButtonItems(
    BuildContext context,
    List<T> data,
  ) {
    final textTheme = context.textTheme;

    return data.mapIndexed((index, item) {
      final isFirst = index == 0;
      final isLast = index == data.length - 1;

      return DropdownItem<T>(
        value: item,
        intrinsicHeight: true,
        closeOnTap: false,
        child: ValueListenableBuilder<List<T>>(
          valueListenable: _valuesNotifier,
          builder: (context, selectedValues, _) {
            final isSelected = selectedValues.contains(item);

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                isFirst ? 20 : 12,
                20,
                isLast ? 20 : 12,
              ),
              child: Row(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IgnorePointer(
                    child: AppCheckbox(
                      enabled: isSelected,
                      onChanged: (value) {},
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        widget.labelBuilder(item),
                        style: textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }).toList();
  }
}

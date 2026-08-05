import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

class AppDropdownField<T> extends StatefulWidget {
  const AppDropdownField({
    required this.items,
    required this.labelBuilder,
    this.selected,
    this.onChanged,
    this.hintText,
    super.key,
  });

  final List<T> items;

  final T? selected;

  final void Function(T? value)? onChanged;

  final String Function(T item) labelBuilder;

  final String? hintText;

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  late final ValueNotifier<T?> _valueNotifier = ValueNotifier(widget.selected);

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final br = BorderRadius.circular(4);
    final hintText = widget.hintText;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        valueListenable: _valueNotifier,
        selectedItemBuilder: (context) => widget.items
            .map(
              (item) => _buildSelectedItem(context, item),
            )
            .toList(),
        items: _buildButtonItems(context, widget.items),
        hint: hintText != null
            ? Text(
                hintText,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        onChanged: (value) {
          _valueNotifier.value = value;
          widget.onChanged?.call(value);
        },
        dropdownSeparator: DropdownSeparator<T>(
          height: 1,
          child: Divider(
            thickness: 1,
            color: colorScheme.outline,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          padding: EdgeInsets.zero,
        ),
        buttonStyleData: ButtonStyleData(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: br,
            color: colorScheme.surfaceContainerHighest,
          ),
          elevation: 0,
        ),
        style: textTheme.bodyLarge,
        dropdownStyleData: DropdownStyleData(
          useRootNavigator: true,
          padding: EdgeInsets.zero,
          maxHeight: context.screenSize.height / 2.5,
          offset: const Offset(0, -2),
          elevation: 1,
          decoration: BoxDecoration(borderRadius: br),
        ),
      ),
    );
  }

  Widget _buildSelectedItem(BuildContext context, T value) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      constraints: BoxConstraints(
        // minHeight: 48,
        maxWidth: context.screenSize.width - 32 * 2 - (20 + 16),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        widget.labelBuilder(value),
        style: textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  List<DropdownItem<T>> _buildButtonItems(
    BuildContext context,
    List<T> data,
  ) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return data.mapIndexed((index, item) {
      final isSelected = item == _valueNotifier.value;

      return DropdownItem<T>(
        value: item,
        intrinsicHeight: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  widget.labelBuilder(item),
                  style: textTheme.bodyLarge,
                ),
              ),

              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

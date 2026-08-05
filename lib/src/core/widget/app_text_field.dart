import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

// const _strutStyle = StrutStyle(forceStrutHeight: false, height: 1.2);

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.initialValue,
    this.onChanged,
    this.expands = false,
    // this.validator,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.onTap,
    this.onTapOutside,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.canRequestFocus = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.canHaveError = false,
    this.errorText,
    this.unfocusOnTapOutside = true,
    this.prefixIcon,
    this.contentPadding,
    this.label,
    this.suffixIcon,
  });

  final TextEditingController? controller;

  final FocusNode? focusNode;

  final String? hintText;

  final String? initialValue;

  final bool expands;

  final List<TextInputFormatter>? inputFormatters;

  final TextInputType? keyboardType;

  final bool obscureText;

  final TextCapitalization textCapitalization;

  final TextInputAction? textInputAction;

  final void Function(String)? onChanged;

  // final String? Function(String?)? validator;

  final void Function(PointerDownEvent)? onTapOutside;

  final void Function()? onTap;

  final int? maxLines;

  final bool enableSuggestions;

  final bool autocorrect;

  final bool canRequestFocus;

  final bool readOnly;

  final bool autofocus;

  final int? maxLength;

  final bool unfocusOnTapOutside;

  final bool canHaveError;

  final String? errorText;

  final Widget? prefixIcon;

  final EdgeInsets? contentPadding;

  final String? label;

  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  bool _isInternalController = false;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      _initController();
    }
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
    _controller.addListener(_onTextChanged);
    _showClearButton = _controller.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() => _showClearButton = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final label = widget.label;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        GestureDetector(
          onTap: widget.onTap,
          child: AbsorbPointer(
            absorbing: widget.onTap != null,
            child: TextFormField(
              // initialValue: widget.initialValue,
              autofocus: widget.autofocus,
              controller: _controller,
              focusNode: widget.focusNode,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              keyboardType: widget.keyboardType,
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              canRequestFocus: widget.canRequestFocus,
              obscureText: widget.obscureText,
              onChanged: widget.onChanged,
              onTapOutside: (event) {
                widget.onTapOutside?.call(event);
                if (widget.unfocusOnTapOutside) {
                  widget.focusNode?.unfocus();
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              autocorrect: widget.autocorrect,
              maxLines: widget.maxLines,
              expands: widget.expands,
              enableSuggestions: widget.enableSuggestions,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              // strutStyle: _strutStyle,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon,
                contentPadding: widget.contentPadding,
                // suffix: Assets.icons.calendar.svg(),
                suffixIcon: widget.suffixIcon,
                // error: errorText != null ? const SizedBox.shrink() : null,
                errorText: widget.errorText != null ? '' : null,
                errorStyle: const TextStyle(fontSize: 0, height: 0.0001),
                counterText: '',
              ),
            ),
          ),
        ),
        if (widget.canHaveError)
          Text(
            widget.errorText ?? '',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
              // height: 1.2,
            ),
            strutStyle: const StrutStyle(forceStrutHeight: true),
          ),
      ],
    );
  }
}

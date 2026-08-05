import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/config.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// Оверлей-виджет для отображения временного сообщения в верхней части экрана.
///
/// Используется совместно с [OverlayEntry]; управляет анимацией появления
/// и исчезновения, по завершении вызывает [onDismiss] для удаления записи.
class AppToastMessage extends StatefulWidget {
  const AppToastMessage({
    required this.title,
    required this.duration,
    required this.onDismiss,
    this.icon,
    super.key,
  });

  final String title;

  /// Иконка слева. Если не передана — иконка не отображается.
  final Widget? icon;

  final Duration duration;

  final VoidCallback onDismiss;

  @override
  State<AppToastMessage> createState() => _AppToastMessageState();
}

class _AppToastMessageState extends State<AppToastMessage> {
  bool _isVisible = false;
  final _animationDuration = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    unawaited(_startLifecycle());
  }

  Future<void> _startLifecycle() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });

    await Future<void>.delayed(widget.duration);

    if (mounted) {
      setState(() => _isVisible = false);

      await Future<void>.delayed(_animationDuration);
      if (mounted) widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Positioned(
      left: UIConfig.kSidePadding,
      right: UIConfig.kSidePadding,
      top: 12,
      child: SafeArea(
        child: AnimatedOpacity(
          duration: _animationDuration,
          opacity: _isVisible ? 1.0 : 0.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  color: Colors.black.withValues(alpha: .06),
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  minLeadingWidth: 0,
                  leading: widget.icon != null
                      ? SizedBox.square(
                          dimension: 24,
                          child: widget.icon,
                        )
                      : null,
                  visualDensity: const VisualDensity(
                    vertical: -4,
                    horizontal: -2,
                  ),
                  dense: true,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.title,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 10, 20, 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

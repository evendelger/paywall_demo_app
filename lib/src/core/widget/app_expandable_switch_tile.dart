import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/theme/theme.dart';

class AppExpandableSwitchTile extends StatefulWidget {
  const AppExpandableSwitchTile({
    required this.header,
    required this.content,
    this.isExpanded = false,
    this.contentPadding = 24,
    super.key,
  });

  final Widget header;

  final Widget content;

  final bool isExpanded;

  final double contentPadding;

  @override
  State<AppExpandableSwitchTile> createState() =>
      _AppExpandableSwitchTileState();
}

class _AppExpandableSwitchTileState extends State<AppExpandableSwitchTile>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  static const _animDuration = AppAnimations.switchTileTransition;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;

    _controller = AnimationController(
      vsync: this,
      duration: _animDuration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.switchTileCurve,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;

      if (_isExpanded) {
        unawaited(_controller.forward());
      } else {
        unawaited(_controller.reverse());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _toggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Row(
            spacing: 4,
            children: [
              Expanded(child: widget.header),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: (math.pi / 2) + (_animation.value * math.pi),
                    child: child,
                  );
                },
                child: Assets.icons.arrowLeft.svg(
                  colorFilter: ColorFilter.mode(
                    colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Align(
              alignment: Alignment.topCenter,
              heightFactor: _animation.value,
              child: Opacity(
                opacity: _animation.value,
                child: SizeTransition(
                  sizeFactor: _animation,
                  child: child,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(top: widget.contentPadding),
            child: widget.content,
          ),
        ),
      ],
    );
  }
}

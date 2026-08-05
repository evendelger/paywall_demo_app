import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template fading_edge}
/// Исчезающий край при скроле
/// {@endtemplate}
class AppFadingEdge extends StatefulWidget {
  /// {@macro fading_edge}
  const AppFadingEdge({
    required this.child,
    super.key,
    this.color,
    this.direction = Axis.vertical,
    this.stops = const [0.0, 0.05, 0.95, 1.0],
    this.onlyBottom = false,
    this.onlyTop = false,
  });

  final Widget child;

  final Color? color;

  final Axis direction;

  final List<double> stops;

  final bool onlyBottom;

  final bool onlyTop;

  @override
  State<AppFadingEdge> createState() => _AppFadingEdgeState();
}

class _AppFadingEdgeState extends State<AppFadingEdge> {
  late List<double> stops;

  @override
  void initState() {
    super.initState();
    _updateStops();
  }

  @override
  void didUpdateWidget(AppFadingEdge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onlyBottom != widget.onlyBottom ||
        oldWidget.onlyTop != widget.onlyTop ||
        oldWidget.stops != widget.stops) {
      _updateStops();
    }
  }

  void _updateStops() {
    stops = widget.stops.toList();

    // Отключаем верхнее затухание
    if (widget.onlyBottom) {
      stops[0] = 0;
      stops[1] = 0;
    }

    // Отключаем нижнее затухание
    if (widget.onlyTop) {
      stops[2] = 1;
      stops[3] = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvas = context.theme.cardColor;
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: widget.direction == Axis.vertical
              ? Alignment.topCenter
              : Alignment.centerLeft,
          end: widget.direction == Axis.vertical
              ? Alignment.bottomCenter
              : Alignment.centerRight,
          colors: [
            widget.color ?? canvas,
            Colors.transparent,
            Colors.transparent,
            widget.color ?? canvas,
          ],
          stops: stops,
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: widget.child,
    );
  }
}

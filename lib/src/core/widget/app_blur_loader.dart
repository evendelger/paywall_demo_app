import 'dart:ui';

import 'package:flutter/material.dart';

/// {@template blur_loader}
/// BlurLoader widget
/// {@endtemplate}
class AppBlurLoader extends StatelessWidget {
  /// {@macro blur_loader}
  const AppBlurLoader({
    required this.child,
    required this.isLoading,
    super.key,
    this.indicator,
  });

  final Widget child;

  final bool isLoading;

  final Widget? indicator;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(child: child),
      AbsorbPointer(
        absorbing: isLoading,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: isLoading
              ? ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4,
                      sigmaY: 4,
                    ),
                    child: Center(
                      child: RepaintBoundary(
                        child: indicator,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    ],
  );
}

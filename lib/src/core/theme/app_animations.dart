import 'package:flutter/animation.dart';

abstract final class AppAnimations {
  static const Duration appButtonTransition = Duration(milliseconds: 200);
  static const Duration navBarTransition = Duration(milliseconds: 500);
  static const Duration switchTileTransition = Duration(milliseconds: 250);

  static const Curve appButtonInCurve = Curves.easeInCubic;
  static const Curve appButtonOutCurve = Curves.easeOutCubic;
  static const Curve switchTileCurve = Curves.easeInOut;
}

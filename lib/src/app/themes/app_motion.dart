import 'package:flutter/animation.dart';

/// Shared motion durations. Aligned to the values already in use across the
/// component kit (state-colour swaps, segmented thumb slide, cross-fades) so
/// every animated surface reads with one consistent tempo.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slide = Duration(milliseconds: 220);
  static const Duration fade = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 320);
}

/// Shared easing curves. `standard` is the kit default (easeOut); `emphasized`
/// gives entrances/large moves a softer settle.
abstract final class AppCurves {
  static const Curve standard = Curves.easeOut;
  static const Curve emphasized = Curves.easeOutCubic;
}

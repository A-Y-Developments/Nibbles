import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';

/// Subtle fade-through: the incoming screen fades in while scaling up from a
/// near-full 0.98, giving navigation a soft settle without a heavy slide.
/// Shared by both the router (full-screen pushes) and the global
/// [PageTransitionsTheme] so every route feels the same.
Widget fadeThroughTransition(Animation<double> animation, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: AppCurves.standard),
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.98, end: 1).animate(
        CurvedAnimation(parent: animation, curve: AppCurves.emphasized),
      ),
      child: child,
    ),
  );
}

/// Platform-default [PageTransitionsBuilder] wiring [fadeThroughTransition]
/// into [ThemeData.pageTransitionsTheme] for Android builder-based routes.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return fadeThroughTransition(animation, child);
  }
}

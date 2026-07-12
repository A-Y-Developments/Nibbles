import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';

/// Wraps [child] with a subtle scale-down while pressed, springing back on
/// release or cancel. Press tracking uses a [Listener] (not a gesture
/// recognizer) so it never competes in the gesture arena — a descendant
/// [InkWell] keeps its ripple and tap. Pass [onTap] to replace a bare
/// [GestureDetector]; omit it to add press feedback around an existing tap
/// handler. Scaling only runs while [enabled] (defaults to `onTap != null`).
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.onTap,
    this.enabled,
    this.pressedScale = 0.96,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool? enabled;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  bool get _enabled => widget.enabled ?? (widget.onTap != null);

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: AppDurations.fast,
      curve: AppCurves.standard,
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: content,
      );
    }

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: content,
    );
  }
}

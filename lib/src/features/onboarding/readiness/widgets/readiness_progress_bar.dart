import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Top progress bar for the 5-step readiness stepper. Each completed segment
/// fills with a color interpolated along
/// maroon -> coral -> butter -> sage as the current step advances.
///
/// PRIVATE to the readiness feature.
class ReadinessProgressBar extends StatelessWidget {
  const ReadinessProgressBar({
    required this.stepCount,
    required this.currentIndex,
    super.key,
  });

  /// Total number of steps (= `readinessQuestionCount`).
  final int stepCount;

  /// 0-based index of the active step. Segments at or before this index are
  /// considered "filled" — the fill color comes from the per-segment ramp.
  final int currentIndex;

  /// Anchor stops for the 4-color ramp.
  static const List<Color> _stops = [
    AppColors.destructive,
    AppColors.coral,
    AppColors.butter,
    AppColors.greenSoft,
  ];

  /// Sample the [_stops] ramp at [t] in [0,1].
  static Color _sample(double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (_stops.length < 2) return _stops.first;
    final segs = _stops.length - 1;
    final scaled = clamped * segs;
    final i = scaled.floor().clamp(0, segs - 1);
    final local = scaled - i;
    return Color.lerp(_stops[i], _stops[i + 1], local) ?? _stops[i];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stepCount, (i) {
        final isLast = i == stepCount - 1;
        final filled = i <= currentIndex;
        final t = stepCount <= 1 ? 1.0 : i / (stepCount - 1);
        final target = filled ? _sample(t) : AppColors.borderSoft;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : AppSizes.xs),
            child: TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOut,
              tween: ColorTween(end: target),
              builder: (context, color, _) => Container(
                height: AppSizes.xs + 2,
                decoration: BoxDecoration(
                  color: color ?? target,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

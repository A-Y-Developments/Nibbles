import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// NIB-83 readiness stepper progress bar.
///
/// Single continuous pill bar: the fill widens AND shifts color as the
/// active step advances through the 6-screen questionnaire. Per-step color
/// stops mirror the Figma audit
/// (.figma-audit/onboarding/readiness-check-{1..6}/screenshot.png):
///
///   step 0 (Q1)  -> coral peach   (gate / intro)
///   step 1 (Q2)  -> destructive   (burgundy)
///   step 2 (Q3)  -> destructive   (burgundy)
///   step 3 (Q4)  -> coral         (salmon)
///   step 4 (Q5)  -> butter        (lime)
///   step 5 (Q6)  -> green         (forest)
///
/// Animated: both width (FractionallySizedBox factor) and fill color
/// cross-fade on step change.
///
/// PRIVATE to the readiness feature.
class ReadinessProgressBar extends StatelessWidget {
  const ReadinessProgressBar({
    required this.stepCount,
    required this.currentIndex,
    super.key,
  });

  /// Total number of steps (= 6 in the NIB-83 flow).
  final int stepCount;

  /// 0-based index of the active step.
  final int currentIndex;

  /// Per-step fill colors aligned with the Figma render. Length must match
  /// the NIB-83 stepCount (6).
  static const List<Color> _stepFillColors = <Color>[
    AppColors.coral,
    AppColors.destructive,
    AppColors.destructive,
    AppColors.coral,
    AppColors.butter,
    AppColors.green,
  ];

  /// Fraction of the track filled at [index]. Q1 reads as 0% to match the
  /// Figma render of the first frame (empty grey track); subsequent steps
  /// step linearly.
  static double _fillForStep(int index, int stepCount) {
    if (stepCount <= 1) return 1;
    final span = stepCount - 1; // 5 increments for 6 steps
    if (index <= 0) return 0;
    if (index >= span) return 1;
    return index / span;
  }

  Color _fillForCurrent() {
    if (_stepFillColors.isEmpty) return AppColors.coral;
    final clampedIdx = currentIndex.clamp(0, _stepFillColors.length - 1);
    return _stepFillColors[clampedIdx];
  }

  @override
  Widget build(BuildContext context) {
    final fraction = _fillForStep(currentIndex, stepCount);
    final fillColor = _fillForCurrent();
    const trackColor = AppColors.borderSoft;
    const height = AppSizes.sm; // 8px track per Figma render.

    return Semantics(
      label: 'Readiness progress',
      value: '${currentIndex + 1} of $stepCount',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              const ColoredBox(
                color: trackColor,
                child: SizedBox.expand(),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                tween: Tween<double>(begin: fraction, end: fraction),
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: TweenAnimationBuilder<Color?>(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                    tween: ColorTween(end: fillColor),
                    builder: (context, color, __) => Container(
                      decoration: BoxDecoration(
                        color: color ?? fillColor,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// 2-up segmented control. Mirrors kit components-segmented preview:
/// track #EAEAEA (borderSoft), radiusFull (pill), active segment greenDeep/cream,
/// labels in Parkinsans display 700/15 (kit `var(--font-display)` 700 15px/1).
///
/// The active fill is a single sliding thumb (matching the sibling
/// `AppSlidingSegmentedControl`) so selection changes glide instead of
/// cross-fading in place.
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  }) : assert(segments.length == 2, 'AppSegmentedControl is 2-up only');

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const double _trackPadding = 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth =
            (constraints.maxWidth - _trackPadding * 2) / segments.length;
        return Container(
          height: AppSizes.segmentedHeight,
          padding: const EdgeInsets.all(_trackPadding),
          decoration: BoxDecoration(
            color: AppColors.borderSoft,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: AppDurations.slide,
                curve: AppCurves.standard,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.greenDeep,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(segments.length, (i) {
                    final active = i == selectedIndex;
                    return SizedBox(
                      width: segmentWidth,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: AppDurations.quick,
                            curve: AppCurves.standard,
                            style: TextStyle(
                              fontFamily: FontFamily.parkinsans,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1,
                              color: active
                                  ? AppColors.cream
                                  : AppColors.greenDeep,
                            ),
                            child: Text(segments[i]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
